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
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        public var tickers: [Ticker]
        public var trades: [TradeModel]
        
        public var addTradePresentation: AddTradePresentationStore.State = .init()
        
        public init(
            path: StackState<Path.State> = .init(),
            tickers: [Ticker] = [],
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
        case fetched([Ticker], [TradeModel])
        
        case tickerTapped(Ticker)
        case tradeTapped(TradeModel)

        case path(StackActionOf<Path>)
        
        case addTradePresentation(AddTradePresentationStore.Action)
        
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
                return .none
                
            case .tradeTapped(let trade):
                state.addTradePresentation.addTradeNavigation = .init(addTradeType: .edit(trade: trade))
                return .none
                
            case .addTradePresentation(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .send(.fetch)
                }
                
            case .delegate, .binding, .path, .addTradePresentation:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        
        Scope(state: \.addTradePresentation, action: \.addTradePresentation) {
            AddTradePresentationStore()
        }
    }
}
