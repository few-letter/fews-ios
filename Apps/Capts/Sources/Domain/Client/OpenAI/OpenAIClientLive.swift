import Foundation

public final class OpenAIClientLive: OpenAIClientProtocol {
    private let apiClient: APIClientProtocol
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    public init(apiClient: APIClientProtocol, apiKey: String) {
        self.apiClient = apiClient
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    public func chat(messages: [OpenAIMessage]) async throws -> String {
        let request = OpenAIChatRequest(messages: messages, stream: false)
        return try await performRequest(request)
    }
    
    public func chatStream(messages: [OpenAIMessage]) -> AsyncThrowingStream<String, Error> {
        let request = OpenAIChatRequest(messages: messages, stream: true)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let apiRequest = try await buildAPIRequest(request)
                    
                    for try await chunk in apiClient.streamRequest(apiRequest) {
                        if let content = try parseStreamChunk(chunk) {
                            continuation.yield(content)
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func performRequest(_ openAIRequest: OpenAIChatRequest) async throws -> String {
        let apiRequest = try await buildAPIRequest(openAIRequest)
        let response = try await apiClient.request(apiRequest, responseType: OpenAIResponse.self)
        
        guard let firstChoice = response.choices.first,
              let message = firstChoice.message else {
            throw OpenAIError.responseParsingFailed
        }
        
        return message.content
    }
    
    private func buildAPIRequest(_ openAIRequest: OpenAIChatRequest) async throws -> APIRequest {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw APIError.invalidURL
        }
        
        var headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        if openAIRequest.stream {
            headers["Accept"] = "text/event-stream"
            headers["Cache-Control"] = "no-cache"
        }
        
        do {
            return try APIRequest.jsonRequest(
                url: url,
                method: .POST,
                body: openAIRequest,
                headers: headers
            )
        } catch let error as APIError {
            switch error {
            case .serverError(401):
                throw OpenAIError.invalidAPIKey
            case .serverError(let code):
                throw OpenAIError.requestFailed("HTTP \(code)")
            default:
                throw OpenAIError.requestFailed(error.localizedDescription)
            }
        } catch {
            throw OpenAIError.requestFailed(error.localizedDescription)
        }
    }
    
    private func parseStreamChunk(_ chunk: String) throws -> String? {
        guard let data = chunk.data(using: .utf8) else {
            return nil
        }
        
        do {
            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let firstChoice = response.choices.first,
                  let delta = firstChoice.delta else {
                return nil
            }
            
            return delta.content
        } catch {
            // Skip parsing errors for incomplete chunks
            return nil
        }
    }
}
