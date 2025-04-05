import Foundation

enum PolygonError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int)
    case decodingError(Error)
    case missingAPIKey
    case noData
    case unknown(String)
}

class PolygonAPI {
    static let shared = PolygonAPI() // Singleton
    private let apiKey = Secrets.polygonApiKey

    private init() {}  // Make the initializer private

    func getCompanyInfo(for symbol: String) async -> Result<CompanyInfo, PolygonError> {
        guard !apiKey.isEmpty else {
            return .failure(.missingAPIKey)
        }

        let urlString = "https://api.polygon.io/v3/reference/tickers/\(symbol)?apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("Status Code: \(statusCode)")  // Debugging
                return .failure(.invalidResponse(statusCode))
            }

            let decodedResponse = try JSONDecoder().decode(CompanyInfoResponse.self, from: data)

            guard decodedResponse.status == "OK", let results = decodedResponse.results else {
                print("Polygon API returned error or missing results") //Debugging
                return .failure(.noData)
            }

            return .success(results)

        } catch {
            print("Network error: \(error)") //Debugging
            return .failure(.networkError(error))
        }
    }

    // Last trade function that was not taken out
    func getLastTrade(for symbol: String) async -> Result<Trade, PolygonError> {
        guard !apiKey.isEmpty else {
            return .failure(.missingAPIKey)
        }

        let urlString = "https://api.polygon.io/v3/trades/\(symbol)/latest?apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                return .failure(.invalidResponse(statusCode))
            }

            let decodedResponse = try JSONDecoder().decode(TradeResponse.self, from: data)

            guard decodedResponse.status == "OK", let trade = decodedResponse.results else {
                return .failure(.noData)
            }

            return .success(trade)

        } catch {
            return .failure(.networkError(error))
        }
    }
}

// MARK: - Data Structures for Polygon API

// Company Info

struct CompanyInfoResponse: Decodable {
    let status: String
    let request_id: String
    let results: CompanyInfo?
}

struct CompanyInfo: Decodable {
    let ticker: String
    let name: String
    let market: String
    let locale: String
    let primary_exchange: String
    let type: String
    let active: Bool
    let currency_name: String
    let cik: String
    let composite_figi: String
    let share_class_figi: String
    let market_cap: Double?
    let phone_number: String
    let address: Address?
    let description: String
    let sic_code: String
    let sic_description: String
    let ticker_root: String
    let homepage_url: String
    let total_employees: Int?
    let list_date: String
    let branding: Branding?
    let share_class_shares_outstanding: Double?
    let weighted_shares_outstanding: Double?
    let round_lot: Int?
}

struct Address: Decodable {
    let address1: String?
    let city: String?
    let state: String?
    let postal_code: String?
}

struct Branding: Decodable {
    let logo_url: String?
    let icon_url: String?
}

// Last Trade info

struct TradeResponse: Decodable {
    let status: String
    let request_id: String
    let results: Trade?
}

struct Trade: Decodable {
    let ticker: String // 'T' field in the response
    let price: Double  // 'p' field
    let size: Int      // 's' field
    let exchange: Int  // 'x' field
    let timestamp: Int // 't' field

    private enum CodingKeys: String, CodingKey {
        case ticker = "T"
        case price = "p"
        case size = "s"
        case exchange = "x"
        case timestamp = "t"
    }
}
