//
//  HomeStore.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
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
        public init(
            path: StackState<Path.State> = .init(),
        ) {
            self.path = path
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear

        case path(StackActionOf<Path>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .binding, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
