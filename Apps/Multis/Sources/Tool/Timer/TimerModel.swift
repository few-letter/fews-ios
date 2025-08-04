import Foundation
import Dependencies
import IdentifiedCollections

public protocol TimerModel: Observable {
    var documents: IdentifiedArrayOf<TimeDocument> { get }
    var documentsByDate: [Date: IdentifiedArrayOf<TimeDocument>] { get }
    
    func fetch()
    func toggle(documentID: TimeDocument.ID)
    func add(document: TimeDocument)
    func update(document: TimeDocument)
    func delete(documentID: TimeDocument.ID)
    func deleteAll(documentID: TimeDocument.ID)
    func isTimerRunning(documentID: TimeDocument.ID) -> Bool
    
    func handleAppWillEnterBackground()
    func handleAppWillEnterForeground()
}

public struct TimeDocumentID: Hashable {
    public var uuid: UUID
    public var date: Date
    
    public init(uuid: UUID, date: Date) {
        self.uuid = uuid
        self.date = Calendar.current.startOfDay(for: date)
    }
}

public enum TimeDocumentIem {
    case task(TaskItem)
    case goal(GoalItem)
    
    var id: UUID {
        switch self {
        case .task(let item):
            return item.id
        case .goal(let item):
            return item.id
        }
    }
    
    var date: Date {
        switch self {
        case .task(let item):
            return item.date
        case .goal(let item):
            return item.startDate
        }
    }
}

public struct TimeDocument: Identifiable {
    public let id: TimeDocumentID
    public let item: TimeDocumentIem
    
    public init(item: TimeDocumentIem, date: Date? = nil) {
        self.id = .init(uuid: item.id, date: date ?? item.date)
        self.item = item
    }
}
