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
    public private(set) var tasks: IdentifiedArrayOf<TaskModel>
    public private(set) var goals: IdentifiedArrayOf<GoalData>
    public private(set) var runningTimers: IdentifiedArrayOf<TimerID> = []
    
    @ObservationIgnored
    @Dependency(\.goalClient) private var goalClient
    @ObservationIgnored
    @Dependency(\.taskClient) private var taskClient
    @ObservationIgnored
    @Dependency(\.continuousClock) private var clock
    
    private var backgroundTimestamps: [String: Date] = [:]
    private var timerTasks: [String: _Concurrency.Task<Void, Never>] = [:]
    
    public init(
        tasks: IdentifiedArrayOf<TaskModel> = [],
        goals: IdentifiedArrayOf<GoalData> = []
    ) {
        self.tasks = tasks
        self.goals = goals
    }
    
    deinit {
        for task in timerTasks.values {
            task.cancel()
        }
    }
    
    public func fetchGoals() {
        self.goals = .init(uniqueElements: goalClient.fetches())
    }
    
    public func fetchTasks() {
        self.tasks = .init(uniqueElements: taskClient.fetches())
    }
    
    public func toggleTimer(for timerID: TimerID) {
        if runningTimers.contains(timerID) {
            stopTimer(for: timerID)
        } else {
            startTimer(for: timerID)
        }
    }
    
    public func toggleTaskTimer(for task: TaskModel) {
        toggleTimer(for: .task(taskId: task.id, date: task.date))
    }
    
    public func toggleGoalTimer(for goal: GoalData) {
        toggleTimer(for: .goal(goalId: goal.id))
    }
    
    public func handleAppWillEnterBackground() {
        let currentTime = Date()
        
        for timerID in runningTimers {
            backgroundTimestamps[timerID.id] = currentTime
            UserDefaults.standard.set(currentTime.timeIntervalSince1970, forKey: "timer_background_\(timerID.id)")
        }
    }
    
    public func handleAppWillEnterForeground() {
        updateBackgroundTimers()
    }
    
    public func stopAllTimers() {
        let currentTimers = Array(runningTimers)
        for timerID in currentTimers {
            stopTimer(for: timerID)
        }
    }
    
    public var runningTimersCount: Int {
        return runningTimers.count
    }
}

extension MultiTimerModel {
    private func startTimer(for timerID: TimerID) {
        guard !self.runningTimers.contains(timerID) else { return }
        self.runningTimers.append(timerID)
        let timerTask = _Concurrency.Task { @MainActor [weak self] in
            while !_Concurrency.Task.isCancelled {
                try? await self?.clock.sleep(for: .milliseconds(100))
                guard self?.runningTimers.contains(timerID) == true else { break }
                self?.updateTime(for: timerID, increment: 100)
            }
        }
        self.timerTasks[timerID.id] = timerTask
    }
    
    private func stopTimer(for timerID: TimerID) {
        self.runningTimers.removeAll { $0 == timerID }
        
        if let timerTask = timerTasks[timerID.id] {
            timerTask.cancel()
            self.timerTasks.removeValue(forKey: timerID.id)
        }
        
        self.saveEntity(for: timerID)
    }
    
    private func updateTime(for timerID: TimerID, increment: Int) {
        switch timerID {
        case .task(let id, _):
            self.tasks[id: id]?.time += increment
        case .goal(let id):
            self.goals[id: id]?.addTime(increment, forDate: .now)
        }
    }
    
    private func saveEntity(for timerID: TimerID) {
        switch timerID {
        case .task(let id, _):
            if let task = self.tasks[id: id] {
                let updatedTask = taskClient.createOrUpdate(taskModel: task)
                tasks[id: id] = updatedTask
            }
        case .goal(let id):
            if let goal = self.goals[id: id] {
                let updatedGoal = goalClient.createOrUpdate(goal: goal)
                self.goals[id: id] = updatedGoal
            }
        }
    }
    
    private func updateBackgroundTimers() {
        let currentTime = Date()
        
        for timerID in runningTimers {
            let key = "timer_background_\(timerID.id)"
            let backgroundStartTime = UserDefaults.standard.double(forKey: key)
            
            if backgroundStartTime > 0 {
                let elapsedSeconds = currentTime.timeIntervalSince1970 - backgroundStartTime
                let elapsedMilliseconds = Int(elapsedSeconds * 1000)
                
                self.updateTime(for: timerID, increment: elapsedMilliseconds)
                
                UserDefaults.standard.removeObject(forKey: key)
                self.backgroundTimestamps.removeValue(forKey: timerID.id)
            }
        }
    }
}
