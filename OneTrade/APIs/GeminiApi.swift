import Foundation

enum GeminiError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int)
    case encodingError(Error)
    case decodingError(Error)
    case missingAPIKey
    case noContent
    case unknown(String)
    case apiRateLimitExceeded

    var errorDescription: String? { // For a better user experience
        switch self {
        case .invalidURL:
            return "Invalid URL for the Gemini API."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let code):
            return "Invalid response from Gemini API (status code: \(code))."
        case .encodingError(let error):
            return "Error encoding the request: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error decoding the response: \(error.localizedDescription)"
        case .missingAPIKey:
            return "Gemini API key is missing."
        case .noContent:
            return "No content received from the Gemini API."
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .apiRateLimitExceeded:
            return "Gemini API rate limit exceeded. Please try again later."
        }
    }
}

struct GeminiRequest: Encodable {
    let contents: [Content]
}

struct Content: Encodable {
    let parts: [Part]
}

struct Part: Encodable {
    let text: String
}

struct GeminiResponse: Decodable {
    let candidates: [Candidate]?
}

struct Candidate: Decodable {
    let content: ResponseContent?
}

struct ResponseContent: Decodable {
    let parts: [ResponsePart]?
    let role: String?
}

struct ResponsePart: Decodable {
    let text: String?
}

class GeminiService {
    static let shared = GeminiService()
    private init() {}

    private let apiKey = Secrets.geminiApiKey // Secure this!
    private let modelName = "gemini-2.0-flash-lite" //Consider using a larger Model!
    private let stockContentPrompt = """
    Return a prompt only in this format and nothing else using the stock symbol provided at the end unless you know nothing in which case return "Information is unavaliable":

    Symbol:
    Exchange:

    Description:

    Industry:
    Sector:
    Address:
    Website:
    Market Cap:
    Employees:
    """

    /// Generate arbitrary content from Gemini
    func generateContent(prompt: String) async -> Result<String, Error> {
        guard !apiKey.isEmpty else {
            return .failure(GeminiError.missingAPIKey)
        }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(GeminiError.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiRequest(contents: [
            Content(parts: [ Part(text: prompt) ])
        ])

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return .failure(GeminiError.encodingError(error))
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                if code == 429 { // Rate limit
                    return .failure(GeminiError.apiRateLimitExceeded)
                }
                return .failure(GeminiError.invalidResponse(code))
            }

            do {
                let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                if let text = geminiResponse.candidates?
                                 .first?
                                 .content?
                                 .parts?
                                 .first?
                                 .text {
                    return .success(text)
                } else {
                    return .failure(GeminiError.noContent)
                }
            } catch {
                return .failure(GeminiError.decodingError(error))
            }

        } catch {
            return .failure(GeminiError.networkError(error))
        }
    }

    /// Convenience for generating the stock‐info prompt
    func generateStockContent(stock: String) async -> Result<String, Error> {
        let fullPrompt = stockContentPrompt + stock
        return await generateContent(prompt: fullPrompt)
    }
}
