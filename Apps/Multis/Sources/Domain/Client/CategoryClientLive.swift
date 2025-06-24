//
//  CategoryClientLive.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftData

public class CategoryClientLive: CategoryClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        let existingCategories = fetches()
        guard existingCategories.isEmpty else {
            return
        }
        
        let mockCategories = generateMockCategories()
        
        for mockCategory in mockCategories {
            let swiftDataCategory = mockCategory.toSwiftDataCategory()
            context.insert(swiftDataCategory)
        }
        
        do {
            try context.save()
            print("Mock category data created successfully: \(mockCategories.count) categories")
        } catch {
            print("Failed to create mock category data: \(error)")
        }
    }
    
    private func generateMockCategories() -> [CategoryModel] {
        let categories = [
            CategoryModel(
                title: "업무",
                color: "#FF6B6B"
            ),
            CategoryModel(
                title: "개인",
                color: "#4ECDC4"
            ),
            CategoryModel(
                title: "학습",
                color: "#45B7D1"
            ),
            CategoryModel(
                title: "운동",
                color: "#96CEB4"
            ),
            CategoryModel(
                title: "기타",
                color: "#FECA57"
            )
        ]
        
        return categories
    }
    
    public func createOrUpdate(categoryModel: CategoryModel) -> CategoryModel {
        do {
            let swiftDataCategory: Category
            
            if let existingCategory = categoryModel.category {
                // toSwiftDataCategory()를 사용해서 일관된 변환 로직 적용
                let convertedCategory = categoryModel.toSwiftDataCategory()
                
                existingCategory.title = convertedCategory.title
                existingCategory.color = convertedCategory.color
                swiftDataCategory = existingCategory
            } else {
                swiftDataCategory = categoryModel.toSwiftDataCategory()
                context.insert(swiftDataCategory)
            }
            
            try context.save()
            
            return CategoryModel(from: swiftDataCategory)
        } catch {
            print("Failed to createOrUpdate category: \(error)")
            return categoryModel
        }
    }
    
    public func fetches() -> [CategoryModel] {
        do {
            let descriptor: FetchDescriptor<Category> = .init()
            let result = try context.fetch(descriptor)
            return result.map { CategoryModel(from: $0) }.sorted()
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    public func delete(categoryModel: CategoryModel) {
        do {
            if let existingCategory = categoryModel.category {
                context.delete(existingCategory)
                print("Category deleted")
                try context.save()
            }
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
} 