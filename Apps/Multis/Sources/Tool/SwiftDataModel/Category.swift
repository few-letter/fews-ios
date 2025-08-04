//
//  Category.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftData

@Model
public final class Category {
  public var id: UUID?
  public var title: String?
  public var color: String?

  @Relationship(deleteRule: .nullify, inverse: \Task.category)
  public var tasks: [Task]?

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
