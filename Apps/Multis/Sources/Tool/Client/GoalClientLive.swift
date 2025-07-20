//
//  GoalClientLive.swift
//  Multis
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import SwiftData

public class GoalClientLive: GoalClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        let existingGoals = fetches()
        guard existingGoals.isEmpty else {
            return
        }
        
        let mockGoals = generateMockGoals()
        
        for mockGoal in mockGoals {
            let swiftDataGoal = mockGoal.toSwiftDataGoal()
            context.insert(swiftDataGoal)
        }
        
        do {
            try context.save()
            print("Mock goal data created successfully: \(mockGoals.count) goals")
        } catch {
            print("Failed to create mock goal data: \(error)")
        }
    }
    
    private func generateMockGoals() -> [GoalData] {
        let calendar = Calendar.current
        let now = Date()
        
        // Simple goal data
        let goals = [
            "Complete project milestone",
            "Learn new technology",
            "Exercise routine",
            "Read technical books"
        ]
        
        // Fetch all categories and create mapping
        let availableCategories = fetchAvailableCategories()
        let categoryMap = Dictionary(
            availableCategories.map { ($0.title, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        
        var mockGoals: [GoalData] = []
        let categoryNames = ["Work", "Learning", "Personal", "Health"]
        
        for (index, title) in goals.enumerated() {
            let categoryName = categoryNames[index % categoryNames.count]
            let category = categoryMap[categoryName]
            
            let startDate = calendar.date(byAdding: .day, value: -Int.random(in: 1...30), to: now) ?? now
            let endDate = Bool.random() ? calendar.date(byAdding: .month, value: Int.random(in: 1...6), to: startDate) : nil
            
            // 시간 데이터 생성 (지난 며칠간의 랜덤한 시간들)
            var times: [Date: Int] = [:]
            let daysToGenerate = Int.random(in: 3...10)
            
            for dayOffset in 0..<daysToGenerate {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                    let dayStart = calendar.startOfDay(for: date)
                    // TaskModel처럼 분 단위를 ms로 변환 (15분~2시간)
                    let minutes = [15, 30, 45, 60, 90, 120].randomElement() ?? 30
                    let timeInMs = minutes * 60 * 1000
                    times[dayStart] = timeInMs
                }
            }
            
            let goal = GoalData(
                title: title,
                startDate: startDate,
                endDate: endDate,
                times: times,
                category: category,
                createdAt: startDate,
                updatedAt: now
            )
            
            mockGoals.append(goal)
        }
        
        return mockGoals
    }
    
    private func fetchAvailableCategories() -> [CategoryModel] {
        do {
            let descriptor: FetchDescriptor<Category> = .init()
            let result = try context.fetch(descriptor)
            return result.map { CategoryModel(from: $0) }
        } catch {
            print("Failed to fetch categories for mock goal data: \(error)")
            return []
        }
    }
    
    public func createOrUpdate(goal: GoalData) -> GoalData {
        do {
            let swiftDataGoal: Goal
            
            if let existingGoal = goal.swiftdata {
                // 기존 객체 업데이트 - updateSwiftData() 메서드 사용
                goal.updateSwiftData()
                swiftDataGoal = existingGoal
            } else {
                // 새 객체 생성
                swiftDataGoal = goal.toSwiftDataGoal()
                context.insert(swiftDataGoal)
            }
            
            try context.save()
            
            return GoalData(from: swiftDataGoal)
        } catch {
            print("Failed to createOrUpdate goal: \(error)")
            return goal
        }
    }
    
    public func fetches() -> [GoalData] {
        do {
            let descriptor: FetchDescriptor<Goal> = .init()
            let result = try context.fetch(descriptor)
            return result.map { GoalData(from: $0) }.sorted()
        } catch {
            print("Failed to fetch goals: \(error)")
            return []
        }
    }
    
    public func delete(goal: GoalData) {
        do {
            if let existingGoal = goal.swiftdata {
                context.delete(existingGoal)
                print("Goal deleted")
                try context.save()
            }
        } catch {
            print("Failed to delete goal: \(error)")
        }
    }
    

} 
