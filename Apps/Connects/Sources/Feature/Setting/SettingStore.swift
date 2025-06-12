//
//  SettingStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/23.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SettingStore {
    @ObservableState
    public struct State: Equatable {
        init() { }
    }
    
    public enum Action: Equatable {
        case onAppear
    }
    
    @Dependency(\.plotClient) var plotClient
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
