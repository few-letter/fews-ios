//
//  QuoteModel.swift
//  Plots
//
//  Created by AI Assistant on 2024.
//

import Foundation
import SwiftData

public struct QuoteModel: Identifiable, Comparable, Equatable {
    public var id: String
    public var page: Int?
    public var quote: String
    
    // SwiftData 객체 참조 (저장용)
    public var swiftDataQuote: Quote?
    
    public init(
        id: String = UUID().uuidString,
        page: Int? = nil,
        quote: String = "",
        swiftDataQuote: Quote? = nil
    ) {
        self.id = id
        self.page = page
        self.quote = quote
        self.swiftDataQuote = swiftDataQuote
    }
    
    // Equatable
    public static func == (lhs: QuoteModel, rhs: QuoteModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Comparable
    public static func < (lhs: QuoteModel, rhs: QuoteModel) -> Bool {
        return lhs.quote < rhs.quote
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension QuoteModel {
    /// SwiftData Quote 객체로부터 QuoteModel 생성
    public init(from swiftDataQuote: Quote) {
        self.init(
            id: swiftDataQuote.id ?? UUID().uuidString,
            page: swiftDataQuote.page,
            quote: swiftDataQuote.quote ?? "",
            swiftDataQuote: swiftDataQuote
        )
    }
    
    /// QuoteModel을 SwiftData Quote 객체로 변환
    public func toSwiftDataQuote() -> Quote {
        return Quote(
            id: self.id,
            page: self.page,
            quote: self.quote
        )
    }
    
    /// QuoteModel의 값들로 참조하고 있는 SwiftData Quote 객체를 업데이트
    public func updateSwiftData() {
        guard let swiftDataQuote = self.swiftDataQuote else { return }
        
        swiftDataQuote.id = self.id
        swiftDataQuote.page = self.page
        swiftDataQuote.quote = self.quote
    }
} 