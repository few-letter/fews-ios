import Foundation
import ComposableArchitecture

// MARK: - OpenAI Models
public struct OpenAIChatRequest: Codable {
    let model: String = "gpt-4o-mini"
    let messages: [OpenAIMessage]
    let stream: Bool
    
    public init(messages: [OpenAIMessage], stream: Bool = false) {
        self.messages = messages
        self.stream = stream
    }
}

public struct OpenAIMessage: Codable {
    let role: String
    let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

public struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIResponseMessage?
    let delta: OpenAIDelta?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message, delta
        case finishReason = "finish_reason"
    }
}

public struct OpenAIResponseMessage: Codable {
    let role: String
    let content: String
}

public struct OpenAIDelta: Codable {
    let role: String?
    let content: String?
}

public struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - OpenAI Client Protocol  
public protocol OpenAIClientProtocol {
    func chat(messages: [OpenAIMessage]) async throws -> String
    func chatStream(messages: [OpenAIMessage]) -> AsyncThrowingStream<String, Error>
}

// MARK: - OpenAI Error
public enum OpenAIError: Error, LocalizedError {
    case invalidAPIKey
    case requestFailed(String)
    case responseParsingFailed
    case streamParsingFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid OpenAI API key"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .responseParsingFailed:
            return "Failed to parse response"
        case .streamParsingFailed:
            return "Failed to parse stream response"
        }
    }
}

// MARK: - DependencyKey
private struct OpenAIClientKey: TestDependencyKey {
    static var testValue: any OpenAIClientProtocol = OpenAIClientTest()
}

extension DependencyValues {
    var openAIClient: any OpenAIClientProtocol {
        get { self[OpenAIClientKey.self] }
        set { self[OpenAIClientKey.self] = newValue }
    }
}

// MARK: - Test Implementation
public struct OpenAIClientTest: OpenAIClientProtocol {
    public func chat(messages: [OpenAIMessage]) async throws -> String {
        return "테스트 OpenAI 응답"
    }
    
    public func chatStream(messages: [OpenAIMessage]) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let testResponse = "테스트 스트림 응답"
                for char in testResponse {
                    continuation.yield(String(char))
                    try? await Task.sleep(nanoseconds: 10_000_000)
                }
                continuation.finish()
            }
        }
    }
}
