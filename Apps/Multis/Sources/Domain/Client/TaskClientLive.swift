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
        
        let taskTitles = [
            "팀 회의 준비",
            "코드 리뷰 진행",
            "버그 수정",
            "새로운 기능 개발",
            "문서 작성",
            "테스트 케이스 작성",
            "데이터베이스 최적화",
            "UI/UX 개선",
            "배포 준비",
            "고객 피드백 검토",
            "API 설계",
            "성능 테스트",
            "보안 검토",
            "프로젝트 계획 수립",
            "멘토링 세션",
            "기술 스터디",
            "백로그 정리",
            "스프린트 계획",
            "일일 스탠드업",
            "회고 미팅"
        ]
        
        let taskTimes = [15, 30, 45, 60, 90, 120, 180, 240] // 분 단위
        
        var mockTasks: [TaskModel] = []
        
        let targetDates = [
            now, // 오늘 날짜
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 2))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 5))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 10))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 15))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 20))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 25))!
        ].map { calendar.startOfDay(for: $0) }
        
        let dateDistribution = [
            (targetDates[0], 5), // 오늘에 5개
            (targetDates[1], 4), // 2일에 4개
            (targetDates[2], 6), // 5일에 6개
            (targetDates[3], 3), // 10일에 3개
            (targetDates[4], 4), // 15일에 4개
            (targetDates[5], 2), // 20일에 2개
            (targetDates[6], 3)  // 25일에 3개
        ]
        
        var titleIndex = 0
        
        for (date, count) in dateDistribution {
            for hour in 0..<count {
                let taskDate = calendar.date(byAdding: .hour, value: 9 + hour * 2, to: date)!
                let title = taskTitles[titleIndex % taskTitles.count]
                let time = taskTimes.randomElement()!
                
                let task = TaskModel(
                    id: UUID(),
                    title: title,
                    time: time * 60 * 1000, // 분을 ms로 변환
                    date: taskDate
                )
                
                mockTasks.append(task)
                titleIndex += 1
            }
        }
        
        return mockTasks
    }
    
    public func createOrUpdate(taskModel: TaskModel) -> TaskModel {
        do {
            let swiftDataTask: Task
            
            if let existingTask = taskModel.task {
                // toSwiftDataTask()를 사용해서 일관된 변환 로직 적용
                let convertedTask = taskModel.toSwiftDataTask()
                
                existingTask.title = convertedTask.title
                existingTask.time = convertedTask.time
                existingTask.date = convertedTask.date
                swiftDataTask = existingTask
            } else {
                swiftDataTask = taskModel.toSwiftDataTask()
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
