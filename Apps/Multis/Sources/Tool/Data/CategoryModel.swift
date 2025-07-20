//
//  CategoryModel.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftData

public struct CategoryModel: Identifiable, Comparable {
    public var id: UUID
    public var title: String
    public var color: String // 색상 코드 (hex)
    
    // SwiftData 객체 참조 (저장용)
    public var category: Category?
    
    public init(
        id: UUID = .init(),
        title: String = "",
        color: String = "#007AFF", // 기본 파란색
        category: Category? = nil
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.category = category
    }
    
    // MARK: Equatable (Comparable의 요구사항)
    public static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Comparable
    public static func < (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.title < rhs.title
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension CategoryModel {
    /// SwiftData Category 객체로부터 CategoryModel 생성
    public init(from swiftDataCategory: Category) {
        self.init(
            id: swiftDataCategory.id ?? .init(),
            title: swiftDataCategory.title ?? "",
            color: swiftDataCategory.color ?? "#007AFF",
            category: swiftDataCategory
        )
    }
    
    /// CategoryModel을 SwiftData Category 객체로 변환
    public func toSwiftDataCategory() -> Category {
        return Category(
            id: self.id,
            title: self.title,
            color: self.color
        )
    }
} 