//
//  TaskClientLive.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import SwiftData

public class TaskClientLive: TaskClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        let existingTasks = fetches()
        guard existingTasks.isEmpty else {
            return
        }
        
        let mockTasks = generateMockTasks()
        
        for mockTask in mockTasks {
            let swiftDataTask = mockTask.toSwiftDataTask()
            context.insert(swiftDataTask)
        }
        
        do {
            try context.save()
            print("Mock data created successfully: \(mockTasks.count) tasks")
        } catch {
            print("Failed to create mock data: \(error)")
        }
    }
    
    private func generateMockTasks() -> [TaskModel] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        // Task classification by category
        let tasksByCategory = [
            ("Work", [
                "Prepare team meeting",
                "Conduct code review",
                "Fix bugs",
                "Develop new feature",
                "Design API",
                "Prepare deployment",
                "Establish project plan"
            ]),
            ("Learning", [
                "Technical study",
                "Mentoring session",
                "Write documentation",
                "Write test cases"
            ]),
            ("Personal", [
                "Daily standup",
                "Retrospective meeting",
                "Organize backlog",
                "Sprint planning"
            ]),
            ("Others", [
                "Database optimization",
                "UI/UX improvement",
                "Review customer feedback",
                "Performance testing",
                "Security review"
            ])
        ]
        
        // Fetch all categories and create mapping
        let availableCategories = fetchAvailableCategories()
        let categoryMap = Dictionary(
            availableCategories.map { ($0.title, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        
        let taskTimes = [15, 30, 45, 60, 90, 120, 180, 240] // in minutes
        
        var mockTasks: [TaskModel] = []
        
        let targetDates = [
            now, // today's date
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 2))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 5))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 10))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 15))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 20))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 25))!
        ].map { calendar.startOfDay(for: $0) }
        
        let dateDistribution = [
            (targetDates[0], 3), // 3 tasks on today
            (targetDates[1], 2), // 2 tasks on 2nd
            (targetDates[2], 3), // 3 tasks on 5th
            (targetDates[3], 2), // 2 tasks on 10th
            (targetDates[4], 2), // 2 tasks on 15th
            (targetDates[5], 1), // 1 task on 20th
            (targetDates[6], 2)  // 2 tasks on 25th
        ]
        
        var categoryIndex = 0
        var taskIndex = 0
        
        for (date, count) in dateDistribution {
            for hour in 0..<count {
                let taskDate = calendar.date(byAdding: .hour, value: 9 + hour * 2, to: date)!
                let time = taskTimes.randomElement()!
                
                // Assign tasks by cycling through categories
                let categoryData = tasksByCategory[categoryIndex % tasksByCategory.count]
                let categoryName = categoryData.0
                let categoryTasks = categoryData.1
                let title = categoryTasks[taskIndex % categoryTasks.count]
                
                let category = categoryMap[categoryName]
                
                let task = TaskModel(
                    id: UUID(),
                    title: title,
                    time: time * 60 * 1000, // convert minutes to ms
                    date: taskDate,
                    category: category
                )
                
                mockTasks.append(task)
                
                taskIndex += 1
                if taskIndex % categoryTasks.count == 0 {
                    categoryIndex += 1
                }
            }
        }
        
        return mockTasks
    }
    
    private func fetchAvailableCategories() -> [CategoryModel] {
        do {
            let descriptor: FetchDescriptor<Category> = .init()
            let result = try context.fetch(descriptor)
            return result.map { CategoryModel(from: $0) }
        } catch {
            print("Failed to fetch categories for mock data: \(error)")
            return []
        }
    }
    
    public func createOrUpdate(taskModel: TaskModel) -> TaskModel {
        do {
            let swiftDataTask: Task
            
            if let existingTask = taskModel.task {
                existingTask.title = taskModel.title
                existingTask.time = taskModel.time
                existingTask.date = taskModel.date
                existingTask.category = taskModel.category?.category
                swiftDataTask = existingTask
            } else {
                swiftDataTask = Task(
                    id: taskModel.id,
                    title: taskModel.title,
                    date: taskModel.date,
                    time: taskModel.time,
                    category: taskModel.category?.category
                )
                context.insert(swiftDataTask)
            }
            
            try context.save()
            
            return TaskModel(from: swiftDataTask)
        } catch {
            print("Failed to createOrUpdate task: \(error)")
            return taskModel
        }
    }
    
    public func fetches() -> [TaskModel] {
        do {
            let descriptor: FetchDescriptor<Task> = .init()
            let result = try context.fetch(descriptor)
            return result.map { TaskModel(from: $0) }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    public func delete(taskModel: TaskModel) {
        do {
            if let existingTask = taskModel.task {
                context.delete(existingTask)
                print("Task deleted")
                try context.save()
            }
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}

public class TaskClientTest: TaskClient {
    public func createOrUpdate(taskModel: TaskModel) -> TaskModel {
        fatalError()
    }
    
    public func fetches() -> [TaskModel] {
        fatalError()
    }
    
    public func delete(taskModel: TaskModel) {
        fatalError()
    }
}
