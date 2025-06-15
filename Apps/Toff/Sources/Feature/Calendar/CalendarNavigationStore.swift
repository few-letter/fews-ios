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
    @ObservableState
    public struct State: Equatable {
        public var selectedDate = Date()
        
        public init(selectedDate: Date = Date()) {
            self.selectedDate = selectedDate
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case dateSelected(Date)
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
            case .onAppear:
                return .none
                
            case let .dateSelected(date):
                state.selectedDate = date
                return .none
                
            case .delegate, .binding:
                return .none
            }
        }
    }
}
