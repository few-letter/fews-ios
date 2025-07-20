//
//  Category.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import SwiftData
import Foundation

@Model
public final class Category {
    public var id: UUID?
    public var title: String?
    public var color: String?
    
    // 이 카테고리에 속하는 Task들과의 관계
    @Relationship(deleteRule: .nullify, inverse: \Task.category)
    public var tasks: [Task]?
    
    // 이 카테고리에 속하는 Goal들과의 관계
    @Relationship(deleteRule: .nullify, inverse: \Goal.category)
    public var goals: [Goal]?
    
    public init(
        id: UUID? = .init(),
        title: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.tasks = []
        self.goals = []
    }
} 
