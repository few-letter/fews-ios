//
//  Task.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import SwiftData

public typealias MultisTask = Task

@Model
public final class Task {
  public var id: UUID?
  public var title: String?
  public var time: Int?
  public var date: Date?

  // 카테고리와의 관계
  public var category: Category?

  public init(
    id: UUID? = .init(),
    title: String? = nil,
    date: Date? = nil,
    time: Int? = nil,
    category: Category? = nil
  ) {
    self.id = id
    self.title = title
    self.time = time
    self.date = date
    self.category = category
  }
}
