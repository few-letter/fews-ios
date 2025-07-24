//
//  MultiTimerModel.swift
//  Multis
//
//  Created by 송영모 on 7/20/25.
//

import Foundation
import IdentifiedCollections
import Dependencies

@Observable
public class MultiTimerModel: TimerModel {
    public private(set) var documents: IdentifiedArrayOf<TimeDocument> = []
    private var runningDocuments: IdentifiedArrayOf<TimeDocument> = []
    
    public var documentsByDate: [Date: [TimeDocument]] {
        let groupedByDate = Dictionary(grouping: documents) { document in
            Calendar.current.startOfDay(for: document.date)
        }
        
        return groupedByDate.mapValues { documentsForDate in
            documentsForDate.sorted { lhs, rhs in
                // Task를 먼저, 그 다음 Goal, 그리고 시간 역순으로 정렬
                switch (lhs, rhs) {
                case (.task(let lhsTask), .task(let rhsTask)):
                    return lhsTask.time > rhsTask.time
                case (.goal(let lhsGoal), .goal(let rhsGoal)):
                    return lhsGoal.totalTime > rhsGoal.totalTime
                case (.task, .goal):
                    return true
                case (.goal, .task):
                    return false
                }
            }
        }
    }
    
    @ObservationIgnored
    @Dependency(\.goalClient) private var goalClient
    @ObservationIgnored
    @Dependency(\.taskClient) private var taskClient
    @ObservationIgnored
    @Dependency(\.continuousClock) private var clock
    
    private var backgroundTimestamps: [String: Date] = [:]
    private var timerTasks: [String: _Concurrency.Task<Void, Never>] = [:]
    
    public init() {}
    
    deinit {
        for task in timerTasks.values {
            task.cancel()
        }
    }
    
    public func fetch() {
        let tasks = taskClient.fetches().map { TimeDocument.task($0) }
        let goals = goalClient.fetches().map { TimeDocument.goal($0) }
        self.documents = IdentifiedArrayOf(uniqueElements: tasks + goals)
    }
    
    public func toggleTimer(document: TimeDocument) {
        if runningDocuments.contains(document) {
            stopTimer(for: document)
        } else {
            startTimer(for: document)
        }
    }
    
    public func isTimerRunning(document: TimeDocument) -> Bool {
        return runningDocuments.contains(document)
    }
    
    public func handleAppWillEnterBackground() {
        let currentTime = Date()
        
        for document in runningDocuments {
            backgroundTimestamps[document.id.uuidString] = currentTime
            UserDefaults.standard.set(currentTime.timeIntervalSince1970, forKey: "timer_background_\(document.id)")
        }
    }
    
    public func handleAppWillEnterForeground() {
        updateBackgroundTimers()
    }
}

extension MultiTimerModel {
    private func startTimer(for document: TimeDocument) {
        guard !runningDocuments.contains(document) else { return }
        runningDocuments.append(document)
        
        let timerTask = _Concurrency.Task { @MainActor [weak self] in
            while !_Concurrency.Task.isCancelled {
                try? await self?.clock.sleep(for: .milliseconds(100))
                guard self?.runningDocuments.contains(document) == true else { break }
                self?.updateTime(for: document, increment: 100)
            }
        }
        
        timerTasks[document.id.uuidString] = timerTask
    }
    
    private func stopTimer(for document: TimeDocument) {
        runningDocuments.removeAll { $0.id == document.id }
        
        if let timerTask = timerTasks[document.id.uuidString] {
            timerTask.cancel()
            timerTasks.removeValue(forKey: document.id.uuidString)
        }
        
        saveEntity(for: document)
    }
    
    private func updateTime(for document: TimeDocument, increment: Int) {
        switch document {
        case .task(let task):
            if let updatedTask = documents[id: task.id] {
                if case .task(var taskData) = updatedTask {
                    taskData.time += increment
                    documents[id: task.id] = .task(taskData)
                }
            }
        case .goal(let goal):
            if let updatedGoal = documents[id: goal.id] {
                if case .goal(var goalData) = updatedGoal {
                    goalData.addTime(increment, forDate: .now)
                    documents[id: goal.id] = .goal(goalData)
                }
            }
        }
    }
    
    private func saveEntity(for document: TimeDocument) {
        switch document {
        case .task(let task):
            if let currentDoc = documents[id: task.id] {
                if case .task(let taskData) = currentDoc {
                    let updatedTask = taskClient.createOrUpdate(taskModel: taskData)
                    documents[id: task.id] = .task(updatedTask)
                }
            }
        case .goal(let goal):
            if let currentDoc = documents[id: goal.id] {
                if case .goal(let goalData) = currentDoc {
                    let updatedGoal = goalClient.createOrUpdate(goal: goalData)
                    documents[id: goal.id] = .goal(updatedGoal)
                }
            }
        }
    }
    
    private func updateBackgroundTimers() {
        let currentTime = Date()
        
        for document in runningDocuments {
            let key = "timer_background_\(document.id)"
            let backgroundStartTime = UserDefaults.standard.double(forKey: key)
            
            if backgroundStartTime > 0 {
                let elapsedSeconds = currentTime.timeIntervalSince1970 - backgroundStartTime
                let elapsedMilliseconds = Int(elapsedSeconds * 1000)
                
                updateTime(for: document, increment: elapsedMilliseconds)
                
                UserDefaults.standard.removeObject(forKey: key)
                backgroundTimestamps.removeValue(forKey: document.id.uuidString)
            }
        }
    }
}
