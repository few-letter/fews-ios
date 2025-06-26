//
//  CleanedTextClient.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import Foundation

public final class CleanedTextClientLive: CleanedTextClientProtocol {
    private let openAIClient: OpenAIClientProtocol
    
    public init(openAIClient: OpenAIClientProtocol) {
        self.openAIClient = openAIClient
    }
    
    // MARK: - Public Methods
    public func cleanTextStream(_ request: CleaningRequest) -> AsyncThrowingStream<String, Error> {
        guard !request.originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: CleanedTextError.emptyText)
            }
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // Phase 1: OCR 오류 수정 및 원본 정보 유지하며 정리
                    let phase1Result = try await cleanTextPhase1(request)
                    
                    // Phase 2: 최종 정리 (스트림으로 반환)
                    let phase2Request = CleaningRequest(
                        originalText: phase1Result,
                        option: request.option,
                        additionalInstructions: request.additionalInstructions
                    )
                    
                    for try await chunk in cleanTextPhase2Stream(phase2Request) {
                        continuation.yield(chunk)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: CleanedTextError.openAIClientError(error))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Phase 1: OCR 오류 수정 및 원본 정보 유지하며 정리
    private func cleanTextPhase1(_ request: CleaningRequest) async throws -> String {
        let messages = buildPhase1Messages(for: request)
        return try await openAIClient.chat(messages: messages)
    }
    
    /// Phase 2: 최종 정리 (스트림)
    private func cleanTextPhase2Stream(_ request: CleaningRequest) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let messages = buildPhase2Messages(for: request)
                    
                    for try await chunk in openAIClient.chatStream(messages: messages) {
                        continuation.yield(chunk)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Phase 1용 메시지 구성 (원본 정보 유지하며 정리)
    private func buildPhase1Messages(for request: CleaningRequest) -> [OpenAIMessage] {
        let systemPrompt = """
        다음 텍스트를 OCR 오류를 수정하고 가독성을 높여 정리해주세요. **원본 언어를 절대 변경하지 마세요.**
        **모든 중요한 정보를 반드시 유지해주세요.**
        
        반드시 유지해야 할 정보들:
        - URL, 링크, 웹사이트 주소
        - 이메일 주소, 전화번호
        - 날짜, 시간, 숫자, 금액
        - 고유명사, 회사명, 제품명
        - 주소, 위치 정보
        - 모든 데이터와 팩트
        
        수정해야 할 부분들:
        - OCR 오류로 인한 깨진 문자나 띄어쓰기
        - 문단 구분을 명확히 하기
        - 문맥상 어색한 부분을 자연스럽게 다듬기
        - 반복되는 줄바꿈이나 공백 정리
        
        **절대 하지 말아야 할 것:**
        - 정보 삭제나 생략
        - 링크나 URL 제거
        - 숫자나 데이터 변경
        - 언어 번역
        
        **중요: 원본이 한국어면 한국어로, 영어면 영어로, 일본어면 일본어로 유지해주세요.**
        모든 정보를 보존하면서 텍스트의 구조와 가독성만 향상시켜주세요.
        """
        
        let userMessage = """
        다음은 OCR로 추출된 원본 텍스트입니다. 모든 정보를 유지하면서 정리해주세요:
        
        \(request.originalText)
        """
        
        return [
            OpenAIMessage(role: "system", content: systemPrompt),
            OpenAIMessage(role: "user", content: userMessage)
        ]
    }
    
    /// Phase 2용 메시지 구성 (최종 정리)
    private func buildPhase2Messages(for request: CleaningRequest) -> [OpenAIMessage] {
        var systemPrompt = request.option.systemPrompt
        
        // 추가 지시사항이 있다면 시스템 프롬프트에 추가
        if let additionalInstructions = request.additionalInstructions,
           !additionalInstructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            systemPrompt += "\n\n추가 요청사항:\n\(additionalInstructions)"
        }
        
        // Phase 2임을 명시
        systemPrompt += "\n\n**이 텍스트는 이미 1차 정리가 완료된 텍스트입니다. 위의 형식에 맞춰 최종 정리해주세요.**"
        
        let userMessage = """
        다음은 1차 정리가 완료된 텍스트입니다. 이를 최종 정리해주세요:
        
        \(request.originalText)
        """
        
        return [
            OpenAIMessage(role: "system", content: systemPrompt),
            OpenAIMessage(role: "user", content: userMessage)
        ]
    }
}

