import Foundation
import Dependencies
import IdentifiedCollections

public protocol TimerModel: Observable {
    var documents: IdentifiedArrayOf<TimeDocument> { get }
    var documentsByDate: [Date: [TimeDocument]] { get }
    func fetch()
    func toggleTimer(document: TimeDocument)
    func isTimerRunning(document: TimeDocument) -> Bool
    func handleAppWillEnterBackground()
    func handleAppWillEnterForeground()
}

public enum TimeDocument: Identifiable {
    case task(TaskData)
    case goal(GoalData)
    
    public var id: UUID {
        switch self {
        case .task(let taskModel):
            return taskModel.id
        case .goal(let goalData):
            return goalData.id
        }
    }
    
    public var date: Date {
        switch self {
        case .task(let taskData):
            return taskData.date
        case .goal(let goalData):
            // Goal은 항일 오늘 날짜로 처리 (또는 다른 로직 필요시 수정)
            return .now
        }
    }
    
    public var title: String {
        switch self {
        case .task(let taskData):
            return taskData.title
        case .goal(let goalData):
            return goalData.title
        }
    }
}
