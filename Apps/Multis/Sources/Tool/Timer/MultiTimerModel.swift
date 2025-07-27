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
    
    public var documentsByDate: [Date: IdentifiedArrayOf<TimeDocument>] {
        var groupedByDate: [Date: IdentifiedArrayOf<TimeDocument>] = [:]
        for document in documents {
            groupedByDate[document.id.date, default: []].append(document)
        }
        return groupedByDate
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
        let tasks: [TimeDocument] = taskClient.fetches().map { .init(item: .task($0)) }
        let goals: [TimeDocument] = goalClient.fetches().flatMap { item in
            return item.times.map { key, value in
                return .init(item: .goal(item), date: key)
            }
        }
        self.documents = IdentifiedArrayOf(uniqueElements: tasks + goals)
    }
    
    public func toggle(documentID: TimeDocument.ID) {
        guard let document = documents[id: documentID] else { return }
        
        if runningDocuments.contains(document) {
            stopTimer(for: document)
        } else {
            startTimer(for: document)
        }
    }
    
    public func add(document: TimeDocument, date: Date?) {
        switch document.item {
        case .task(let item):
            let new = taskClient.createOrUpdate(task: item)
            self.documents.append(.init(item: .task(new)))
        case .goal(let item):
            return
        }
    }
    
    public func update(document: TimeDocument) {
        switch document.item {
        case .task(let item):
            let new = taskClient.createOrUpdate(task: item)
            self.documents[id: document.id] = .init(item: .task(new))
        case .goal(let item):
            let new = goalClient.createOrUpdate(goal: item)
            self.documents[id: document.id] = .init(item: <#T##TimeDocumentIem#>, date: <#T##Date?#>) .goal(new)
        }
    }
    
    public func delete(documentID: TimeDocument.ID) {
        guard let document = documents[id: documentID] else { return }
        
        if runningDocuments.contains(document) {
            stopTimer(for: document)
        }
        documents.remove(id: documentID)
        
        switch document {
        case .task(let item):
            taskClient.delete(task: item)
        case .goal(let goalData):
            
            goalClient.delete(goal: goalData)
        }
    }
    
    public func deleteAll(documentID: TimeDocument.ID) {
        
    }
    
    public func isTimerRunning(documentID: TimeDocument.ID) -> Bool {
        guard let document = documents[id: documentID] else { return false }
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
                    let updatedTask = taskClient.createOrUpdate(task: taskData)
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
