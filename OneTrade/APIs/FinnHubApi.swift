import Foundation

enum FinnhubError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for Finnhub API."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .missingAPIKey:
            return "Finnhub API key is missing."
        }
    }
}

struct NewsArticle: Decodable {
    let headline: String
    let summary: String? // Summary might be nil sometimes.
    let datetime: Int
}

class FinnhubNewsService {
    static let shared = FinnhubNewsService()
    private init() {}
    
    private let apiKey = Secrets.finnHubApiKey  // Ensure your Finnhub API key is securely stored in Secrets
    
    /// Fetches company news for the given symbol between two dates.
    func getCompanyNews(for symbol: String, from startDate: String, to endDate: String) async -> Result<[NewsArticle], FinnhubError> {
        guard !apiKey.isEmpty else { return .failure(.missingAPIKey) }
        
        let urlString = "https://finnhub.io/api/v1/company-news?symbol=\(symbol)&from=\(startDate)&to=\(endDate)&token=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let articles = try JSONDecoder().decode([NewsArticle].self, from: data)
            return .success(articles)
        } catch {
            return .failure(.networkError(error))
        }
    }
}

