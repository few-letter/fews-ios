//
//  Plan.swift
//  FewRetros
//
//  Created by 송영모 on 6/9/25.
//

import Foundation
import SwiftData

@Model
public final class Plan {
    public var title: String?
    public var startDate: Date?
    public var endDate: Date?
    public var createdAt: Date?
    
    @Relationship(deleteRule: .cascade)
    public var history: [PlanHistory]? = []
    
    public init(
        title: String,
        startDate: Date,
        endDate: Date,
        createAt: Date,
        history: [PlanHistory] = [],
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createAt
        self.history = history
    }
}

@Model
public final class PlanHistory {
    public var ms: Int
    
    public var plan: Plan?
    
    public init(ms: Int) {
        self.ms = ms
    }
}
