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
    
    // SwiftData 객체 참조 (저장용)
    public var task: Task?
    
    public init(
        id: UUID = .init(),
        title: String = "",
        time: Int = 0, // ms 단위
        date: Date = .now,
        task: Task? = nil
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.date = date
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
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension TaskModel {
    /// SwiftData Task 객체로부터 TaskModel 생성
    /// SwiftData의 time(분) → TaskModel의 time(ms) 변환
    public init(from swiftDataTask: Task) {
        let timeInMinutes = swiftDataTask.time ?? 0
        let timeInMs = timeInMinutes * 60 * 1000 // 분 → ms 변환
        
        self.init(
            id: swiftDataTask.id ?? .init(),
            title: swiftDataTask.title ?? .init(),
            time: timeInMs,
            date: swiftDataTask.date ?? .now,
            task: swiftDataTask
        )
    }
    
    /// TaskModel을 SwiftData Task 객체로 변환
    /// TaskModel의 time(ms) → SwiftData의 time(분) 변환
    public func toSwiftDataTask() -> Task {
        let timeInMinutes = Int(ceil(Double(self.time) / (60 * 1000))) // ms → 분 변환 (올림)
        
        return Task(
            id: self.id,
            title: self.title,
            date: self.date,
            time: timeInMinutes
        )
    }
}
