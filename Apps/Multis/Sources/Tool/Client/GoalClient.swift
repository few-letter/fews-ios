//
//  GoalClient.swift
//  Multis
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol GoalClient {
    func createOrUpdate(goal: GoalItem) -> GoalItem
    func fetches() -> [GoalItem]
    func delete(goal: GoalItem)
}

// MARK: - DependencyKey
private struct GoalClientKey: TestDependencyKey {
    static var testValue: any GoalClient = GoalClientTest()
}

extension DependencyValues {
    var goalClient: any GoalClient {
        get { self[GoalClientKey.self] }
        set { self[GoalClientKey.self] = newValue }
    }
}

// MARK: - Test Implementation
public struct GoalClientTest: GoalClient {
    public func createOrUpdate(goal: GoalItem) -> GoalItem {
        return goal
    }
    
    public func fetches() -> [GoalItem] {
        return []
    }
    
    public func delete(goal: GoalItem) {
        // Test implementation
    }
} 
