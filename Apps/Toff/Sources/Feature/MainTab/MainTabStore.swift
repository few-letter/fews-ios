//
//  MainTabStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

public enum MainTab: String, CaseIterable, Equatable {
    case calendars = "캘린더"
    case stats = "히스토리"
    case settings = "내정보"
    
    public var systemImage: String {
        switch self {
        case .calendars:
            return "calendar"
        case .stats:
            return "clock.arrow.circlepath"
        case .settings:
            return "person.circle"
        }
    }
}

@Reducer
public struct MainTabStore {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: MainTab = .calendars
        public var calendars = CalendarNavigationStore.State()
        public var stats = StatNavigationStore.State()
        public var settings = SettingsStore.State()
        
        public init(
            selectedTab: MainTab = .calendars,
            calendars: CalendarNavigationStore.State = .init(),
            stats: StatNavigationStore.State = .init(),
            settings: SettingsStore.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.calendars = calendars
            self.stats = stats
            self.settings = settings
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tabSelected(MainTab)
        
        case calendars(CalendarNavigationStore.Action)
        case stats(StatNavigationStore.Action)
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
                
            case .calendars, .stats, .settings:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
