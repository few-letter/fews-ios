import Foundation

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Error
public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int)
    case textEncodingError
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .textEncodingError:
            return "Text encoding error"
        }
    }
}

// MARK: - API Request
public struct APIRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
    
    public init(url: URL, method: HTTPMethod = .GET, headers: [String: String] = [:], body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

// MARK: - API Client Protocol
public protocol APIClientProtocol {
    func request<T: Codable>(_ request: APIRequest, responseType: T.Type) async throws -> T
    func requestData(_ request: APIRequest) async throws -> Data
    func streamRequest(_ request: APIRequest) -> AsyncThrowingStream<String, Error>
}

// MARK: - API Client Implementation
public final class APIClient: APIClientProtocol {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<T: Codable>(_ request: APIRequest, responseType: T.Type) async throws -> T {
        let data = try await requestData(request)
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    public func requestData(_ request: APIRequest) async throws -> Data {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        // Set headers
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    public func streamRequest(_ request: APIRequest) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                var isFinished = false
                
                func safeContinuation(action: () -> Void) {
                    guard !isFinished else { return }
                    action()
                }
                
                func safeFinish(error: Error? = nil) {
                    guard !isFinished else { return }
                    isFinished = true
                    if let error = error {
                        continuation.finish(throwing: error)
                    } else {
                        continuation.finish()
                    }
                }
                
                func safeYield(_ value: String) {
                    guard !isFinished else { return }
                    continuation.yield(value)
                }
                
                do {
                    var urlRequest = URLRequest(url: request.url)
                    urlRequest.httpMethod = request.method.rawValue
                    urlRequest.httpBody = request.body
                    
                    // Set headers
                    for (key, value) in request.headers {
                        urlRequest.setValue(value, forHTTPHeaderField: key)
                    }
                    
                    let (asyncBytes, response) = try await session.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        safeFinish(error: APIError.invalidResponse)
                        return
                    }
                    
                    guard 200...299 ~= httpResponse.statusCode else {
                        safeFinish(error: APIError.serverError(httpResponse.statusCode))
                        return
                    }
                    
                    var buffer = Data()
                    var textBuffer = ""
                    
                    for try await byte in asyncBytes {
                        guard !isFinished else { break }
                        
                        buffer.append(byte)
                        
                        // Try to convert accumulated bytes to string
                        if let partialString = String(data: buffer, encoding: .utf8) {
                            textBuffer += partialString
                            buffer.removeAll() // Clear buffer after successful conversion
                            
                            // Process complete lines ending with \n\n
                            while let range = textBuffer.range(of: "\n\n") {
                                guard !isFinished else { break }
                                
                                let chunk = String(textBuffer[..<range.lowerBound])
                                // Safely update textBuffer with remaining content
                                if range.upperBound < textBuffer.endIndex {
                                    textBuffer = String(textBuffer[range.upperBound...])
                                } else {
                                    textBuffer = ""
                                }
                                
                                let lines = chunk.components(separatedBy: "\n")
                                for line in lines {
                                    guard !isFinished else { break }
                                    
                                    if line.hasPrefix("data: ") {
                                        let data = String(line.dropFirst(6))
                                        if data == "[DONE]" {
                                            safeFinish()
                                            return
                                        }
                                        if !data.isEmpty {
                                            safeYield(data)
                                        }
                                    }
                                }
                            }
                        }
                        // If string conversion fails, keep accumulating bytes
                        // This handles partial UTF-8 sequences
                    }
                    
                    // Process any remaining data in textBuffer
                    if !textBuffer.isEmpty && !isFinished {
                        let lines = textBuffer.components(separatedBy: "\n")
                        for line in lines {
                            guard !isFinished else { break }
                            
                            if line.hasPrefix("data: ") {
                                let data = String(line.dropFirst(6))
                                if data == "[DONE]" {
                                    safeFinish()
                                    return
                                }
                                if !data.isEmpty {
                                    safeYield(data)
                                }
                            }
                        }
                    }
                    
                    safeFinish()
                } catch {
                    safeFinish(error: error)
                }
            }
        }
    }
}

// MARK: - JSON Helper Extensions
extension APIRequest {
    public static func jsonRequest<T: Codable>(
        url: URL,
        method: HTTPMethod = .POST,
        body: T,
        headers: [String: String] = [:]
    ) throws -> APIRequest {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(body)
        
        var requestHeaders = headers
        requestHeaders["Content-Type"] = "application/json"
        
        return APIRequest(
            url: url,
            method: method,
            headers: requestHeaders,
            body: jsonData
        )
    }
}
