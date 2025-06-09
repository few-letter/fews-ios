import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture
import IdentifiedCollections
import WidgetKit

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Identifiable {
        public let id: UUID
        public let date: Date
        
        var docs: IdentifiedArrayOf<Doc> = []
        var selectedDocId: UUID
        
        var newKeep: String = ""
        var newProblem: String = ""
        var newTry: String = ""
        
        var selectedDoc: Doc? { docs[id: selectedDocId] }
        
        public init(id: UUID = .init(), date: Date) {
            self.id = id
            self.date = date
            self.selectedDocId = id
        }
    }
    
    public enum Action {
        case onAppear
        case onDisappear
        case refresh
        case docTapped(Doc)
        case inputRecord(type: RecordType, context: String)
        case commitRecord(type: RecordType)
        case deleteRecord(type: RecordType, offset: IndexSet)
        case recordsLoaded([Record])
        case recordsUpdated
    }
    
    public init() {}
    
    @Dependency(\.modelContext) var modelContext
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.docs = .init(uniqueElements: state.date.allDatesInMonth().map { docDate in
                    if Calendar.current.isDate(state.date, inSameDayAs: docDate) {
                        return .init(id: state.selectedDocId, originDate: state.date, date: docDate)
                    } else {
                        return .init(originDate: state.date, date: docDate)
                    }
                })
                
                return .send(.refresh)
                
            case .onDisappear:
                state.newKeep = ""
                state.newProblem = ""
                state.newTry = ""
                return .none
                
            case .refresh:
                state.newKeep = ""
                state.newProblem = ""
                state.newTry = ""
                
                return .run { send in
                    let records: [Record] = (try? modelContext.fetch(.init())) ?? []
                    await send(.recordsLoaded(records))
                }
                
            case let .recordsLoaded(records):
                for id in state.docs.ids {
                    let date = state.docs[id: id]?.date
                    state.docs[id: id]?.records = records.filter({
                        Calendar.current.isDate($0.showAt ?? .now, inSameDayAs: date ?? .now)
                    })
                }
                return .none
                
            case let .docTapped(doc):
                let prevId = state.selectedDocId
                let currentId = doc.id
                
                state.docs[id: prevId]?.selectedDate = doc.date
                state.docs[id: currentId]?.selectedDate = doc.date
                
                state.selectedDocId = currentId
                return .none
                
            case let .inputRecord(type, context):
                if context.isEmpty { return .none }
                
                switch type {
                case .keep:
                    state.newKeep = context
                case .problem:
                    state.newProblem = context
                case .try:
                    state.newTry = context
                }
                return .none
                
            case let .commitRecord(type):
                let context: String
                switch type {
                case .keep: context = state.newKeep
                case .problem: context = state.newProblem
                case .try: context = state.newTry
                }
                
                return .run { [state] send in
                    let selectedDate = state.selectedDoc?.date ?? .now
                    modelContext.insert(Record(type: type, context: context, showAt: selectedDate.time, updateAt: .now))
                    try? modelContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                    await send(.recordsUpdated)
                }
                
            case let .deleteRecord(type, offset):
                let records: [Record]
                switch type {
                case .keep: records = offset.compactMap({ state.selectedDoc?.keeps[$0] })
                case .problem: records = offset.compactMap({ state.selectedDoc?.problems[$0] })
                case .try: records = offset.compactMap({ state.selectedDoc?.tries[$0] })
                }
                
                return .run { send in
                    for record in records {
                        modelContext.delete(record)
                    }
                    try? modelContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                    await send(.recordsUpdated)
                }
                
            case .recordsUpdated:
                return .send(.refresh)
            }
        }
    }
}

private extension Date {
    func allDatesInMonth() -> [Date] {
        let calendar = Calendar.current
        
        let startOfMonth = self.startOfMonth
        var prevDates: [Date] = []
        var prevDate = calendar.date(byAdding: .day, value: -1, to: startOfMonth) ?? .now
        
        while calendar.dateComponents([.weekday], from: prevDate).weekday != 7 {
            prevDates.append(prevDate)
            guard let date = calendar.date(byAdding: .day, value: -1, to: prevDate) else { return [] }
            prevDate = date
        }
        
        let endOfMonth: Date = self.endOfMonth
        var nextDates: [Date] = []
        var nextDate: Date = calendar.date(byAdding: .day, value: 1, to: endOfMonth) ?? .now
        
        while calendar.dateComponents([.weekday], from: nextDate).weekday != 1 {
            nextDates.append(nextDate)
            guard let date = calendar.date(byAdding: .day, value: 1, to: nextDate) else { return [] }
            nextDate =  date
        }
        
        var currentDates: [Date] = []
        var currentDate: Date = startOfMonth
        
        while !Calendar.current.isDate(currentDate, inSameDayAs: endOfMonth.add(byAdding: .day, value: 1)) {
            currentDates.append(currentDate)
            guard let date = calendar.date(byAdding: .day, value: 1, to: currentDate) else { return [] }
            currentDate =  date
        }
        
        return prevDates.reversed() + currentDates + nextDates
    }
    
    func add(byAdding: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: byAdding, value: value, to: self) ?? self
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var time: Date {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        let nowComponents = cal.dateComponents(x, from: .now)
        var components = cal.dateComponents(x, from: self)
        
        components.hour = nowComponents.hour
        components.minute = nowComponents.minute
        components.second = nowComponents.second
        
        return cal.date(from: components)!
    }
} 