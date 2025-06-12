//
//  RootStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import ComposableArchitecture

public enum RootScene: Hashable {
    case home
}

@Reducer
public struct RootStore {
    @ObservableState
    public struct State {
        var path: [RootScene] = []
        
        var home: HomeStore.State = .init()
    }
    
    public enum Action {
        case home(HomeStore.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .home:
                return .none
            }
        }
        
        Scope(state: \.home, action: \.home) {
            HomeStore()
        }
    }
}
