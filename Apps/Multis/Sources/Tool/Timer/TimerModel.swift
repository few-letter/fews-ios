import Foundation
import Dependencies
import IdentifiedCollections

public protocol TimerModel: Observable {
    var tasks: IdentifiedArrayOf<TaskModel> { get }
    var goals: IdentifiedArrayOf<GoalData> { get }
    var runningTimers: IdentifiedArrayOf<TimerID> { get }
    var runningTimersCount: Int { get }
    
    func fetchGoals()
    func fetchTasks()
    func toggleTimer(for timerID: TimerID)
    func toggleTaskTimer(for task: TaskModel)
    func toggleGoalTimer(for goal: GoalData)
    func stopAllTimers()
    func handleAppWillEnterBackground()
    func handleAppWillEnterForeground()
}
