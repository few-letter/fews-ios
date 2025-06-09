//
//  RootStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import ComposableArchitecture

enum RootScene: Hashable {
    case home
}

@Reducer
struct RootStore {
    @ObservableState
    struct State: Equatable {
        var path: [RootScene] = []
        
        var home: HomeStore.State = .init()
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case home(HomeStore.Action)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .home:
                return .none
            }
        }
        
        Scope(state: \.home, action: \.home) {
            HomeStore()
        }
    }
}
