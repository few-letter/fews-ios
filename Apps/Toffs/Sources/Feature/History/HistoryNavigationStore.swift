//
//  HistoryNavigationStore.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct HistoryNavigationStore {
    @Reducer
    public enum Path {
        case tickerDetail(TickerDetailStore)
        case tradeDetail(TradeDetailStore)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        public var tickers: [TickerModel]
        public var trades: [TradeModel]
        
        public init(
            path: StackState<Path.State> = .init(),
            tickers: [TickerModel] = [],
            trades: [TradeModel] = []
        ) {
            self.path = path
            self.tickers = tickers
            self.trades = trades
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetch
        case fetched([TickerModel], [TradeModel])
        
        case tickerTapped(TickerModel)
        case tradeTapped(TradeModel)

        case path(StackActionOf<Path>)
        
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
                state.trades = trades.sorted { $0.date > $1.date }
                return .none
                
            case .tickerTapped(let ticker):
                state.path.append(.tickerDetail(.init(ticker: ticker)))
                return .none
                
            case .tradeTapped(let trade):
                state.path.append(.tradeDetail(.init(trade: trade)))
                return .none
                
            case .path(.element(id: _, action: .tradeDetail(.delegate(let action)))):
                switch action {
                case .requestDismiss:
                    _ = state.path.popLast()
                    return .send(.fetch)
                }
                
            case .delegate, .binding, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)

    }
}
