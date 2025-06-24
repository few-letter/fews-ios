//
//  TaskModel.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import SwiftData

public struct TaskModel: Identifiable, Comparable {
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
    public static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Comparable
    public static func < (lhs: TaskModel, rhs: TaskModel) -> Bool {
        return lhs.date < rhs.date
    }
    
    /// 시간을 0.01초 단위로 표시
    public var displayTime: String {
        // 0.01초(10ms) 단위로 변환
        let displaySeconds = Double(time) / 1000.0
        return String(format: "%.2f", displaySeconds)
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension TaskModel {
    /// SwiftData Task 객체로부터 TaskModel 생성 (ms 단위 통일)
    public init(from swiftDataTask: Task) {
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
    public func toSwiftDataTask() -> Task {
        return Task(
            id: self.id,
            title: self.title,
            date: self.date,
            time: self.time, // ms 단위 그대로 저장
            category: self.category?.toSwiftDataCategory()
        )
    }
}
