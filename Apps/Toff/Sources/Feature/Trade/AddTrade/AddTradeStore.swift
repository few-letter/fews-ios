//
//  AddTradeStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
public struct AddTradeStore {
    @ObservableState
    public struct State {
        public var trade: Trade
        public var tickers: IdentifiedArrayOf<Ticker> = []
        
        public init(trade: Trade) {
            self.trade = trade
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([Ticker])
        
        case delegate(Delegate)
        public enum Delegate {
            
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            
            case .onAppear:
                return .none
                
            case .fetch:
                return .none
                
            case .fetched(let tickers):
                state.tickers = .init(uniqueElements: tickers)
                return .none
            }
        }
    }
}
