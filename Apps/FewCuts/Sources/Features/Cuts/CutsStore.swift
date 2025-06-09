//
//  File.swift
//  FewCuts
//
//  Created by 송영모 on 6/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CutsStore {
    @ObservableState
    public struct State: Equatable {
        
    }
    
    public enum Action {
        case onAppear
    }
    
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
