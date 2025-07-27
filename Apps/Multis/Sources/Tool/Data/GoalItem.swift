//
//  GoalModel.swift
//  Multis
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import SwiftData

public struct GoalItem: Identifiable, Comparable {
    public var id: UUID
    public var title: String
    public var startDate: Date
    public var endDate: Date?
    public var times: [Date: Int] //  날짜별 시간 (ms 단위)
    public var category: CategoryModel?
    public var createdAt: Date
    public var updatedAt: Date
    
    // SwiftData 객체 참조 (저장용)
    public var swiftdata: Goal?
    
    public init(
        id: UUID = .init(),
        title: String = "",
        startDate: Date = .now,
        endDate: Date? = nil,
        times: [Date: Int] = [:],
        category: CategoryModel? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        swiftdata: Goal? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.times = times
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.swiftdata = swiftdata
    }
    
    // MARK: Equatable (Comparable의 요구사항)
    public static func == (lhs: GoalItem, rhs: GoalItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Comparable
    public static func < (lhs: GoalItem, rhs: GoalItem) -> Bool {
        return lhs.createdAt > rhs.createdAt
    }
    
    /// 카테고리 이름 (카테고리가 없으면 "No Category" 반환)
    public var categoryDisplayName: String {
        return category?.title ?? "No Category"
    }
    
    /// 총 누적 시간 (ms 단위)
    public var totalTime: Int {
        return times.values.reduce(0, +)
    }
    
    /// 총 시간을 0.01초 단위로 표시
    public var displayTime: String {
        let displaySeconds = Double(totalTime) / 1000.0
        return String(format: "%.2f", displaySeconds)
    }
    
    /// 특정 날짜의 시간 (ms 단위)
    public func timeForDate(_ date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return times[dayStart] ?? 0
    }
    
    /// 특정 날짜에 시간 추가
    public mutating func addTime(_ time: Int, forDate date: Date) {
        let dayStart = Calendar.current.startOfDay(for: date)
        times[dayStart, default: 0] += time
        updatedAt = .now
    }
    
    /// 특정 날짜의 시간 설정
    public mutating func setTime(_ time: Int, forDate date: Date) {
        let dayStart = Calendar.current.startOfDay(for: date)
        times[dayStart] = time
        updatedAt = .now
    }
    
    /// 오늘 날짜의 시간
    public var todayTime: Int {
        return timeForDate(.now)
    }
    
    /// 오늘 시간을 0.01초 단위로 표시
    public var todayDisplayTime: String {
        let displaySeconds = Double(todayTime) / 1000.0
        return String(format: "%.2f", displaySeconds)
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension GoalItem {
    /// SwiftData Goal 객체로부터 GoalModel 생성
    public init(from goal: Goal) {
        let categoryModel = goal.category != nil ? CategoryModel(from: goal.category!) : nil
        
        self.init(
            id: goal.id ?? .init(),
            title: goal.title ?? "",
            startDate: goal.startDate ?? .now,
            endDate: goal.endDate,
            times: goal.times ?? [:],
            category: categoryModel,
            createdAt: goal.createdAt ?? .now,
            updatedAt: goal.updatedAt ?? .now,
            swiftdata: goal
        )
    }
    
    /// GoalModel을 SwiftData Goal 객체로 변환
    public func toSwiftDataGoal() -> Goal {
        return Goal(
            id: self.id,
            title: self.title,
            startDate: self.startDate,
            endDate: self.endDate,
            times: self.times,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            category: self.category?.category
        )
    }
    
    /// GoalModel의 값들로 참조하고 있는 SwiftData Goal 객체를 업데이트
    public func updateSwiftData() {
        guard let goal = self.swiftdata else { return }
        
        goal.title = self.title
        goal.startDate = self.startDate
        goal.endDate = self.endDate
        goal.times = self.times
        goal.updatedAt = self.updatedAt
        goal.category = self.category?.category
    }
} 
