//
//  Goal.swift
//  Multis
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import SwiftData

@Model
public final class Goal {
  public var id: UUID?
  public var title: String?
  public var startDate: Date?
  public var endDate: Date?
  public var times: [Date: Int]?
  public var createdAt: Date?
  public var updatedAt: Date?

  public var category: Category?

  public init(
    id: UUID? = .init(),
    title: String? = nil,
    startDate: Date? = nil,
    endDate: Date? = nil,
    times: [Date: Int]? = nil,
    createdAt: Date? = .now,
    updatedAt: Date? = .now,
    category: Category? = nil
  ) {
    self.id = id
    self.title = title
    self.startDate = startDate
    self.endDate = endDate
    self.times = times
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.category = category
  }
}
