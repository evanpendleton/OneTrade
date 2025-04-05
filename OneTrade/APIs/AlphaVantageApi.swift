import Foundation

enum AlphavantageError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case missingAPIKey
    case noData
}

class AlphavantageAPI {
    static let shared = AlphavantageAPI()  // Singleton instance
    private let apiKey = Secrets.alphaVantageApiKey  // Ensure your API key is set here

    private init() {}

    func getCompanyInfo(for symbol: String) async -> Result<CompanyInfo, AlphavantageError> {
        guard !apiKey.isEmpty else {
            return .failure(.missingAPIKey)
        }
        
        let urlString = "https://www.alphavantage.co/query?function=OVERVIEW&symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard data.count > 0 else {
                return .failure(.noData)
            }
            
            let decoder = JSONDecoder()
            let alphaResponse = try decoder.decode(AlphavantageCompanyOverview.self, from: data)
            
            guard !alphaResponse.name.isEmpty else {
                return .failure(.noData)
            }
            
            let companyInfo = CompanyInfo(
                ticker: alphaResponse.symbol,
                name: alphaResponse.name,
                market: alphaResponse.assetType,
                locale: alphaResponse.country,
                primary_exchange: alphaResponse.exchange,
                type: alphaResponse.assetType,
                active: true,
                currency_name: alphaResponse.currency,
                cik: alphaResponse.cik,
                composite_figi: "",
                share_class_figi: "",
                market_cap: Double(alphaResponse.marketCapitalization) ?? nil,
                phone_number: "",
                address: Address(
                    address1: alphaResponse.address,
                    city: "",
                    state: "",
                    postal_code: ""
                ),
                description: alphaResponse.description,
                sic_code: alphaResponse.sector,
                sic_description: alphaResponse.industry,
                ticker_root: alphaResponse.symbol,
                homepage_url: alphaResponse.website,
                total_employees: Int(alphaResponse.fullTimeEmployees) ?? nil,
                list_date: "",
                branding: nil,
                share_class_shares_outstanding: nil,
                weighted_shares_outstanding: nil,
                round_lot: nil
            )
            
            return .success(companyInfo)
            
        } catch {
            return .failure(.decodingError(error))
        }
    }
    
    func getDailyTimeSeries(for symbol: String) async -> Result<AlphavantageTimeSeriesResponse, AlphavantageError> {
    let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(apiKey)"
    guard let url = URL(string: urlString) else {
        return .failure(.invalidURL)
    }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        // Print the raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(AlphavantageTimeSeriesResponse.self, from: data)
            return .success(response)
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            return .failure(.decodingError(decodingError))
        }
    } catch {
        return .failure(.networkError(error))
    }
    }
}

// MARK: - Alphavantage Company Overview Response Model
struct AlphavantageCompanyOverview: Decodable {
    let symbol: String
    let assetType: String
    let name: String
    let description: String
    let cik: String
    let exchange: String
    let currency: String
    let country: String
    let sector: String
    let industry: String
    let address: String
    let marketCapitalization: String
    let website: String
    let fullTimeEmployees: String

    private enum CodingKeys: String, CodingKey {
        case symbol = "Symbol"
        case assetType = "AssetType"
        case name = "Name"
        case description = "Description"
        case cik = "CIK"
        case exchange = "Exchange"
        case currency = "Currency"
        case country = "Country"
        case sector = "Sector"
        case industry = "Industry"
        case address = "Address"
        case marketCapitalization = "MarketCapitalization"
        case website = "Website"
        case fullTimeEmployees = "FullTimeEmployees"
    }
}

// MARK: - Alphavantage Daily Time Series Models
struct AlphavantageTimeSeriesResponse: Decodable {
    let timeSeries: [String: DailyTimeSeries]
    
    private enum CodingKeys: String, CodingKey {
        case timeSeries = "Time Series (Daily)"
    }
}

struct DailyTimeSeries: Decodable {
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    
    private enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}
