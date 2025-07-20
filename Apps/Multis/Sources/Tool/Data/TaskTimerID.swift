//
//  TaskTimerID.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation

public struct TaskTimerID: Hashable, Identifiable {
    public var id: UUID { taskId }
    public let taskId: UUID
    public let date: Date
    
    public init(taskId: UUID, date: Date) {
        self.taskId = taskId
        self.date = Calendar.current.startOfDay(for: date)
    }
}
