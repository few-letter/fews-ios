//
//  MainTabView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture
import Feature_Common

public enum MainTab: String, CaseIterable, Equatable {
    case calendars
    case documents
    case settings
    
    public var systemImage: String {
        switch self {
        case .calendars:
            return "calendar"
        case .documents:
            return "doc.text"
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
        public var documents: DocumentNavigationStore.State
        public var settings: SettingsStore.State
        
        public init(
            selectedTab: MainTab = .calendars,
            calendars: CalendarNavigationStore.State = .init(),
            documents: DocumentNavigationStore.State = .init(),
            settings: SettingsStore.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.calendars = calendars
            self.documents = documents
            self.settings = settings
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tabSelected(MainTab)
        
        case calendars(CalendarNavigationStore.Action)
        case documents(DocumentNavigationStore.Action)
        case settings(SettingsStore.Action)
    }
    
    public init() {}
    
    @Dependency(\.adClient) private var adClient
    @Dependency(\.analyticsClient) private var analyticsClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.calendars, action: \.calendars) {
            CalendarNavigationStore()
        }
        
        Scope(state: \.documents, action: \.documents) {
            DocumentNavigationStore()
        }
        
        Scope(state: \.settings, action: \.settings) {
            SettingsStore()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    await analyticsClient.start()
                    await adClient.showOpeningAd(appID: nil)
                }
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .calendars, .documents, .settings:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
