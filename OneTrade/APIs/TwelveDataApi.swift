import Foundation

enum TwelveDataError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case missingAPIKey
    case noData
}

class TwelveDataAPI {
    static let shared = TwelveDataAPI()  // Singleton instance
    private let apiKey = Secrets.twelveDataApiKey  // Ensure your Twelve Data API key is set here

    private init() {}

    // Fetch company info using Twelve Data's company endpoint
    func getCompanyInfo(for symbol: String) async -> Result<CompanyInfo, TwelveDataError> {
        guard !apiKey.isEmpty else {
            return .failure(.missingAPIKey)
        }
        
        let urlString = "https://api.twelvedata.com/company?symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard data.count > 0 else { return .failure(.noData) }
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(TwelveDataCompanyResponse.self, from: data)
            
            // Verify company info exists (for example, ensure the name isn’t empty)
            guard !response.name.isEmpty else {
                return .failure(.noData)
            }
            
            let companyInfo = CompanyInfo(
                ticker: response.symbol,
                name: response.name,
                market: response.exchange,
                locale: response.country,
                primary_exchange: response.exchange,
                type: "Equity",  // Default value; adjust as needed
                active: true,
                currency_name: response.currency,
                cik: "",
                composite_figi: "",
                share_class_figi: "",
                market_cap: Double(response.market_cap) ?? nil,
                phone_number: "",
                address: Address(
                    address1: response.address,
                    city: response.city,
                    state: response.state,
                    postal_code: response.postal_code
                ),
                description: response.description,
                sic_code: response.sector,
                sic_description: response.industry,
                ticker_root: response.symbol,
                homepage_url: response.website,
                total_employees: Int(response.employees) ?? nil,
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
    
    // Fetch daily time series data using Twelve Data's time_series endpoint
    func getDailyTimeSeries(for symbol: String) async -> Result<TwelveDataTimeSeriesResponse, TwelveDataError> {
        guard !apiKey.isEmpty else { return .failure(.missingAPIKey) }
        
        let urlString = "https://api.twelvedata.com/time_series?symbol=\(symbol)&interval=1day&outputsize=100&apikey=\(apiKey)"
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
            let response = try decoder.decode(TwelveDataTimeSeriesResponse.self, from: data)
            return .success(response)
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    // New function to fetch the current stock price using Twelve Data's price endpoint
    func getCurrentPrice(for symbol: String) async -> Result<Double, TwelveDataError> {
        guard !apiKey.isEmpty else { return .failure(.missingAPIKey) }
        
        let urlString = "https://api.twelvedata.com/price?symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard data.count > 0 else { return .failure(.noData) }
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(TwelveDataPriceResponse.self, from: data)
            if let price = Double(response.price) {
                return .success(price)
            } else {
                return .failure(.decodingError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Price not found"])))
            }
        } catch {
            return .failure(.networkError(error))
        }
    }
}

// MARK: - Twelve Data Company Response Model
struct TwelveDataCompanyResponse: Decodable {
    let symbol: String
    let name: String
    let country: String
    let exchange: String
    let currency: String
    let market_cap: String
    let website: String
    let description: String
    let industry: String
    let sector: String
    let employees: String
    let address: String
    let city: String
    let state: String
    let postal_code: String

    private enum CodingKeys: String, CodingKey {
        case symbol, name, country, exchange, currency, website, description, industry, sector, employees, address, city, state, postal_code
        case market_cap = "market_cap"
    }
}

// MARK: - Twelve Data Daily Time Series Models
struct TwelveDataTimeSeriesResponse: Decodable {
    let values: [TwelveDataDailyTimeSeries]
}

struct TwelveDataDailyTimeSeries: Decodable {
    let datetime: String
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
}

// MARK: - Twelve Data Price Response Model
struct TwelveDataPriceResponse: Decodable {
    let price: String
}
