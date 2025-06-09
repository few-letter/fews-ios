//
//  SettingStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/23.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingStore {
    @ObservableState
    struct State: Equatable {
        init() { }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.plotClient) var plotClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}
