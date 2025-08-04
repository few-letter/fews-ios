//
//  TaskModel.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import SwiftData

public struct TaskData: Identifiable, Comparable {
  public var id: UUID
  public var title: String
  public var time: Int // milliseconds (ms) 단위로 관리
  public var date: Date
  public var category: CategoryModel?

  // SwiftData 객체 참조 (저장용)
  public var task: Task?

  public init(
    id: UUID = .init(),
    title: String = "",
    time: Int = 0, // ms 단위
    date: Date = .now,
    category: CategoryModel? = nil,
    task: Task? = nil
  ) {
    self.id = id
    self.title = title
    self.time = time
    self.date = date
    self.category = category
    self.task = task
  }

  // MARK: Equatable (Comparable의 요구사항)

  public static func == (lhs: TaskData, rhs: TaskData) -> Bool {
    return lhs.id == rhs.id
  }

  // MARK: Comparable

  public static func < (lhs: TaskData, rhs: TaskData) -> Bool {
    return lhs.date < rhs.date
  }

  /// 시간을 0.01초 단위로 표시
  public var displayTime: String {
    // 0.01초(10ms) 단위로 변환
    let displaySeconds = Double(time) / 1000.0
    return String(format: "%.2f", displaySeconds)
  }

  // MARK: - Sorting Methods

  /// 카테고리 title로 정렬 (같은 카테고리끼리 묶어서 보여줌)
  /// 카테고리가 없는 항목들은 맨 아래로
  public static func sortedByCategory(_ tasks: [TaskData]) -> [TaskData] {
    return tasks.sorted { lhs, rhs in
      let lhsCategory = lhs.category?.title ?? "zzz_no_category"
      let rhsCategory = rhs.category?.title ?? "zzz_no_category"

      if lhsCategory != rhsCategory {
        return lhsCategory < rhsCategory
      }

      // 같은 카테고리 내에서는 날짜순으로 정렬
      return lhs.date > rhs.date
    }
  }

  /// 카테고리 title로 정렬하되, 시간순으로 2차 정렬
  public static func sortedByCategoryAndTime(_ tasks: [TaskData]) -> [TaskData] {
    return tasks.sorted { lhs, rhs in
      let lhsCategory = lhs.category?.title ?? "zzz_no_category"
      let rhsCategory = rhs.category?.title ?? "zzz_no_category"

      if lhsCategory != rhsCategory {
        return lhsCategory < rhsCategory
      }

      // 같은 카테고리 내에서는 시간이 많은 순으로 정렬
      if lhs.time != rhs.time {
        return lhs.time > rhs.time
      }

      // 시간도 같으면 날짜순으로
      return lhs.date > rhs.date
    }
  }

  /// 카테고리별로 그룹화한 Dictionary 반환
  public static func groupedByCategory(_ tasks: [TaskData]) -> [String: [TaskData]] {
    let grouped = Dictionary(grouping: tasks) { task in
      task.category?.title ?? "No Category"
    }

    // 각 그룹 내에서 시간순으로 정렬
    return grouped.mapValues { tasks in
      tasks.sorted { lhs, rhs in
        if lhs.time != rhs.time {
          return lhs.time > rhs.time
        }
        return lhs.date > rhs.date
      }
    }
  }

  /// 카테고리 이름 (카테고리가 없으면 "No Category" 반환)
  public var categoryDisplayName: String {
    return category?.title ?? "No Category"
  }
}

// MARK: - SwiftData <-> Model Conversion Extensions

public extension TaskData {
  /// SwiftData Task 객체로부터 TaskModel 생성 (ms 단위 통일)
  init(from swiftDataTask: Task) {
    let categoryModel = swiftDataTask.category != nil ? CategoryModel(from: swiftDataTask.category!) : nil
    self.init(
      id: swiftDataTask.id ?? .init(),
      title: swiftDataTask.title ?? "",
      time: swiftDataTask.time ?? 0, // 이제 SwiftData도 ms 단위
      date: swiftDataTask.date ?? .now,
      category: categoryModel,
      task: swiftDataTask
    )
  }

  /// TaskModel을 SwiftData Task 객체로 변환 (ms 단위 통일)
  func toSwiftDataTask() -> Task {
    return Task(
      id: id,
      title: title,
      date: date,
      time: time, // ms 단위 그대로 저장
      category: category?.toSwiftDataCategory()
    )
  }
}
