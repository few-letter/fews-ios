//
//  MainTabStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

public enum MainTab: String, CaseIterable, Equatable {
    case calendars
    case history
    case stats
    case settings
    
    public var systemImage: String {
        switch self {
        case .calendars:
            return "calendar"
        case .stats:
            return "chart.pie"
        case .history:
            return "clock.arrow.circlepath"
        case .settings:
            return "person.circle"
        }
    }
}

@Reducer
public struct MainTabStore {
    @ObservableState
    public struct State {
        public var selectedTab: MainTab
        public var calendars: CalendarNavigationStore.State
        public var stats: StatNavigationStore.State
        public var history: HistoryNavigationStore.State
        public var settings:SettingsStore.State
        
        public init(
            selectedTab: MainTab = .calendars,
            calendars: CalendarNavigationStore.State = .init(),
            stats: StatNavigationStore.State = .init(),
            history: HistoryNavigationStore.State = .init(),
            settings: SettingsStore.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.calendars = calendars
            self.stats = stats
            self.history = history
            self.settings = settings
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tabSelected(MainTab)
        
        case calendars(CalendarNavigationStore.Action)
        case stats(StatNavigationStore.Action)
        case history(HistoryNavigationStore.Action)
        case settings(SettingsStore.Action)
    }
    
    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.calendars, action: \.calendars) {
            CalendarNavigationStore()
        }
        
        Scope(state: \.stats, action: \.stats) {
            StatNavigationStore()
        }
        
        Scope(state: \.history, action: \.history) {
            HistoryNavigationStore()
        }
        
        Scope(state: \.settings, action: \.settings) {
            SettingsStore()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .calendars, .stats, .history, .settings:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
