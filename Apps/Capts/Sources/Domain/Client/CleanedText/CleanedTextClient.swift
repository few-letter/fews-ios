//
//  CleanedTextClient.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import Foundation
import ComposableArchitecture

// MARK: - Cleaning Options
public enum CleaningOption: String, CaseIterable {
    case text = "텍스트"
    case list = "리스트" 
    case table = "표"
    
    public var description: String {
        return self.rawValue
    }
    
    public var systemPrompt: String {
        switch self {
        case .text:
            return """
            다음 텍스트를 읽기 쉽게 정리해주세요. **원본 언어를 절대 변경하지 마세요.** 원본 내용을 최대한 유지하면서 다음 사항을 개선해주세요:
            - 문단 구분을 명확히 하기
            - 오타나 띄어쓰기 수정하기
            - 문맥상 어색한 부분이 있다면 자연스럽게 다듬기
            - 중요한 정보는 누락하지 않기
            
            **중요: 원본이 한국어면 한국어로, 영어면 영어로, 일본어면 일본어로 유지해주세요. 언어를 번역하지 마세요.**
            원본 텍스트의 의미와 맥락을 변경하지 말고, 단지 가독성을 높여주세요.
            """
            
        case .list:
            return """
            다음 텍스트를 리스트 형태로 정리해주세요. **원본 언어를 절대 변경하지 마세요.** 원본 내용을 최대한 유지하면서 다음과 같이 구성해주세요:
            - 주요 내용을 항목별로 분류하기
            - 각 항목을 명확한 불릿 포인트로 표현하기
            - 계층 구조가 있다면 들여쓰기로 표현하기
            - 중요도에 따라 순서 정렬하기
            
            **중요: 원본이 한국어면 한국어로, 영어면 영어로, 일본어면 일본어로 유지해주세요. 언어를 번역하지 마세요.**
            원본의 모든 중요한 정보를 포함하되, 리스트 형태로 보기 쉽게 정리해주세요.
            """
            
        case .table:
            return """
            다음 텍스트를 표 형태로 정리해주세요. **원본 언어를 절대 변경하지 마세요.** 원본 내용을 최대한 유지하면서 다음과 같이 구성해주세요:
            - 관련된 정보들을 행과 열로 분류하기
            - 적절한 헤더를 설정하기
            - 마크다운 표 형식으로 작성하기
            - 빈 셀이 있다면 '-' 또는 'N/A'로 표시하기
            
            **중요: 원본이 한국어면 한국어로, 영어면 영어로, 일본어면 일본어로 유지해주세요. 언어를 번역하지 마세요.**
            표로 정리하기 어려운 내용이 있다면 표 아래에 추가 설명을 덧붙여주세요.
            원본의 모든 정보를 누락하지 않도록 주의해주세요.
            """
        }
    }
}

// MARK: - Cleaning Request
public struct CleaningRequest {
    let originalText: String
    let option: CleaningOption
    let additionalInstructions: String?
    
    public init(originalText: String, option: CleaningOption, additionalInstructions: String? = nil) {
        self.originalText = originalText
        self.option = option
        self.additionalInstructions = additionalInstructions
    }
}

// MARK: - Cleaning Result
public struct CleaningResult {
    let originalText: String
    let cleanedText: String
    let option: CleaningOption
    let timestamp: Date
    
    public init(originalText: String, cleanedText: String, option: CleaningOption, timestamp: Date = Date()) {
        self.originalText = originalText
        self.cleanedText = cleanedText
        self.option = option
        self.timestamp = timestamp
    }
}

// MARK: - CleanedText Client Protocol
public protocol CleanedTextClientProtocol {
    func cleanTextStream(_ request: CleaningRequest) -> AsyncThrowingStream<String, Error>
}

// MARK: - CleanedText Error
public enum CleanedTextError: Error, LocalizedError {
    case emptyText
    case cleaningFailed(String)
    case openAIClientError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .emptyText:
            return "입력된 텍스트가 비어있습니다"
        case .cleaningFailed(let message):
            return "텍스트 정리 실패: \(message)"
        case .openAIClientError(let error):
            return "OpenAI 클라이언트 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - DependencyKey
private struct CleanedTextClientKey: TestDependencyKey {
    static var testValue: any CleanedTextClientProtocol = CleanedTextClientTest()
}

extension DependencyValues {
    var cleanedTextClient: any CleanedTextClientProtocol {
        get { self[CleanedTextClientKey.self] }
        set { self[CleanedTextClientKey.self] = newValue }
    }
}

// MARK: - Test Implementation
public struct CleanedTextClientTest: CleanedTextClientProtocol {
    public func cleanTextStream(_ request: CleaningRequest) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let testResponse = "정리된 텍스트\n\n\(request.originalText)\n\n(테스트 결과)"
                
                for char in testResponse {
                    continuation.yield(String(char))
                    try? await Task.sleep(nanoseconds: 3_000_000)
                }
                continuation.finish()
            }
        }
    }
}

