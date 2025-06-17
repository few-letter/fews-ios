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
    public struct State {
        public var tickers: [Ticker]
        public var trades: [TradeModel]
        
        public init(tickers: [Ticker] = [], trades: [TradeModel] = []) {
            self.tickers = tickers
            self.trades = trades
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetch
        case fetched([Ticker], [TradeModel])
        
        case confirm
        case cancel
        
        case delegate(Delegate)
        
        public enum Delegate {
            case dismiss
        }
    }
    
    @Dependency(\.tickerClient) private var tickerClient
    @Dependency(\.tradeClient) private var tradeClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .send(.fetch)
                
            case .fetch:
                let tickers = tickerClient.fetches()
                let trades = tradeClient.fetches(ticker: nil)
                return .send(.fetched(tickers, trades))
                
            case .fetched(let tickers, let trades):
                state.tickers = tickers
                state.trades = trades
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
