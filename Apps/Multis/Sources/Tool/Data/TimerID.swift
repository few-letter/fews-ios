//
//  TimerID.swift
//  Multis
//
//  Created by 송영모 on 6/25/25.
//

import Foundation

public enum TimerID: Hashable, Identifiable {
    case task(taskId: UUID, date: Date)
    case goal(goalId: UUID)
    
    public var id: String {
        switch self {
        case .task(let taskId, let date):
            let dayStart = Calendar.current.startOfDay(for: date)
            return "task_\(taskId)_\(dayStart.timeIntervalSince1970)"
        case .goal(let goalId):
            return "goal_\(goalId)"
        }
    }
    
    public var entityId: UUID {
        switch self {
        case .task(let taskId, _):
            return taskId
        case .goal(let goalId):
            return goalId
        }
    }
    
    public var isTask: Bool {
        switch self {
        case .task:
            return true
        case .goal:
            return false
        }
    }
    
    public var isGoal: Bool {
        return !isTask
    }
    
    public var taskDate: Date? {
        switch self {
        case .task(_, let date):
            return date
        case .goal:
            return nil
        }
    }
} 