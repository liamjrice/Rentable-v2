import Foundation

class AIService {
    
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "gemini-2.5-flash") {
        self.apiKey = apiKey
        self.model = model
    }
    
    convenience init() {
        self.init(apiKey: Config.geminiAPIKey)
    }
    
    func sendMessage(userMessage: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://generativelanguage.googleapis.com/v1/models/\(model):generateContent?key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(AIServiceError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [["text": userMessage]]
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(AIServiceError.jsonSerializationFailed(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(AIServiceError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                completion(.failure(AIServiceError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, message: message)))
                return
            }

            guard let data = data else {
                completion(.failure(AIServiceError.noData))
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let candidates = json["candidates"] as? [[String: Any]],
                      let content = candidates.first?["content"] as? [String: Any],
                      let parts = content["parts"] as? [[String: Any]],
                      let text = parts.first?["text"] as? String else {
                    completion(.failure(AIServiceError.invalidJSONStructure))
                    return
                }
                completion(.success(text))
            } catch {
                completion(.failure(AIServiceError.jsonParsingFailed(error)))
            }
        }.resume()
    }
}

// MARK: - Error Types

enum AIServiceError: LocalizedError {
    case invalidURL
    case jsonSerializationFailed(Error)
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case noData
    case invalidJSONStructure
    case jsonParsingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .jsonSerializationFailed(let error):
            return "Failed to serialize JSON: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message)"
        case .noData:
            return "No data received from server"
        case .invalidJSONStructure:
            return "Invalid JSON structure in response"
        case .jsonParsingFailed(let error):
            return "Failed to parse JSON: \(error.localizedDescription)"
        }
    }
}

