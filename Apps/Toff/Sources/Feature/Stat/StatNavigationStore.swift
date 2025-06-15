//
//  S.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct StatNavigationStore {
    @ObservableState
    public struct State: Equatable {
        public var tickers: IdentifiedArrayOf<Ticker>
        
        public init(tickers: IdentifiedArrayOf<Ticker> = []) {
            self.tickers = tickers
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case confirm
        case cancel
        
        case delegate(Delegate)
        
        public enum Delegate {
            case dismiss
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .confirm:
                return .none
                
            case .cancel:
                return .send(.delegate(.dismiss))
                
            case .delegate, .binding:
                return .none
            }
        }
    }
}
