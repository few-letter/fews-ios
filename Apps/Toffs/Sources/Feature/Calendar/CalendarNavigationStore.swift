//
//  CalendarStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CalendarNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        public var calendarHome: CalendarHomeStore.State
        
        public init(
            path: StackState<Path.State> = .init(),
            calendarHome: CalendarHomeStore.State = .init()
        ) {
            self.path = path
            self.calendarHome = calendarHome
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case path(StackActionOf<Path>)
        case calendarHome(CalendarHomeStore.Action)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case dismiss
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .calendarHome:
                return .none
                
            case .path, .delegate:
                return .none
            }
        }
        
        Scope(state: \.calendarHome, action: \.calendarHome) {
            CalendarHomeStore()
        }
        .forEach(\.path, action: \.path)
    }
}
