//
//  ImageToTextClientLive.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import Foundation
import UIKit
import Vision

// MARK: - Error Types
public enum TextExtractionError: Error, LocalizedError {
    case invalidImage
    case recognitionFailed
    case noTextFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "유효하지 않은 이미지입니다"
        case .recognitionFailed:
            return "텍스트 인식에 실패했습니다"
        case .noTextFound:
            return "이미지에서 텍스트를 찾을 수 없습니다"
        }
    }
}

// MARK: - Main Client
public class ImageToTextClientLive: ImageToTextClient {
    public init() {}
    
    // MARK: - OCR Processing
    public func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw TextExtractionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("❌ OCR error: \(error)")
                    continuation.resume(throwing: TextExtractionError.recognitionFailed)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: TextExtractionError.noTextFound)
                    return
                }
                
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continuation.resume(throwing: TextExtractionError.noTextFound)
                } else {
                    continuation.resume(returning: text)
                }
            }
            
            // OCR 설정
            request.recognitionLanguages = ["ko-KR", "en-US", "ja-JP"]
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            } catch {
                continuation.resume(throwing: TextExtractionError.recognitionFailed)
            }
        }
    }
}
