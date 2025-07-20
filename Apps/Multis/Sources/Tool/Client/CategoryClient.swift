//
//  CategoryClient.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol CategoryClient {
    func createOrUpdate(categoryModel: CategoryModel) -> CategoryModel
    func fetches() -> [CategoryModel]
    func delete(categoryModel: CategoryModel)
}

private struct CategoryClientKey: TestDependencyKey {
    static var testValue: any CategoryClient = CategoryClientTest()
}

extension DependencyValues {
    var categoryClient: any CategoryClient {
        get { self[CategoryClientKey.self] }
        set { self[CategoryClientKey.self] = newValue }
    }
}

// MARK: - Test Implementation
public struct CategoryClientTest: CategoryClient {
    public func createOrUpdate(categoryModel: CategoryModel) -> CategoryModel {
        return categoryModel
    }
    
    public func fetches() -> [CategoryModel] {
        return []
    }
    
    public func delete(categoryModel: CategoryModel) {
        // Test implementation
    }
} 