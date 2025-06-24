//
//  TradeNavigationStore.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct TradeNavigationStore {
    @Reducer
    public enum Path {}
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>

        public let ticker: Ticker
        public var trade: TradeModel
        public var trades: [TradeModel] = []
        
        public var isFormValid: Bool {
            trade.price > 0 && trade.quantity > 0
        }
        
        public init(
            path: StackState<Path.State> = .init(),
            ticker: Ticker,
            date: Date,
            trade: TradeModel? = nil
        ) {
            self.path = path
            self.ticker = ticker
            
            if let trade {
                self.trade = trade
            } else {
                self.trade = TradeModel(
                    date: date,
                    ticker: ticker
                )
            }
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([TradeModel])
        
        case cancelButtonTapped
        case saveButtonTapped
        
        case path(StackActionOf<Path>)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case requestDismiss
            case requestSaved
        }
    }
    
    public init() {}
    
    @Dependency(\.tradeClient) private var tradeClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .send(.fetch)
                
            case .fetch:
                let trades = tradeClient.fetches(ticker: state.ticker)
                return .send(.fetched(trades))
                
            case .fetched(let trades):
                state.trades = trades
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.requestDismiss))
                
            case .saveButtonTapped:
                let savedTrade = tradeClient.createOrUpdate(trade: state.trade)
                state.trade = savedTrade
                return .send(.delegate(.requestSaved))

            case .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
