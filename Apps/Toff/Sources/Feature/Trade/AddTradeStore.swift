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
    public struct State: Equatable {
        public var trade: Trade
        public var tickers: IdentifiedArrayOf<Ticker>
        
        public init(
            trade: Trade,
            tickers: IdentifiedArrayOf<Ticker> = []
        ) {
            self.trade = trade
            self.tickers = tickers
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([Ticker])
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
