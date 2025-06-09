import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture
import IdentifiedCollections

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State {
        var currentTab: UUID = UUID()
        var calendarTabs: IdentifiedArrayOf<CalendarFeature.State> = []
        var date: Date = .now
        
        public init() {
            let currentTab = UUID()
            self.currentTab = currentTab
            
            self.calendarTabs = [
                .init(id: UUID(), date: Date().add(byAdding: .month, value: -1)),
                .init(id: currentTab, date: Date()),
                .init(id: UUID(), date: Date().add(byAdding: .month, value: 1))
            ]
        }
    }
    
    public enum Action {
        case onAppear
        case tabSelected(UUID)
        case calendar(IdentifiedActionOf<CalendarFeature>)
    }
    
    public init() {}
    
    @Dependency(\.modelContext) var modelContext
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .tabSelected(tabId):
                let currentDate = state.calendarTabs[id: tabId]?.date ?? .now
                let currentIndex = state.calendarTabs.index(id: tabId) ?? 0
                let firstIndex = 0
                let lastIndex = state.calendarTabs.count - 1
                
                switch currentIndex {
                case firstIndex:
                    state.calendarTabs.insert(.init(date: currentDate.add(byAdding: .month, value: -1)), at: 0)
                case lastIndex:
                    state.calendarTabs.append(.init(date: currentDate.add(byAdding: .month, value: 1)))
                default:
                    break
                }
                
                state.currentTab = tabId
                state.date = currentDate
                return .none
                
            case .calendar:
                return .none
            }
        }
        .forEach(\.calendarTabs, action: \.calendar) {
            CalendarFeature()
        }
    }
}

private extension Date {
    func add(byAdding: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: byAdding, value: value, to: self) ?? self
    }
} 