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
        
        public var ticker: Ticker
        public var trade: Trade
        
        public var isFormValid: Bool {
            trade.price > 0 && trade.quantity > 0
        }
        
        public init(
            path: StackState<Path.State> = .init(),
            ticker: Ticker,
            trade: Trade? = nil
        ) {
            self.path = path
            self.ticker = ticker
            
            if let trade {
                self.trade = trade
            } else {
                self.trade = .init()
            }
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case cancelButtonTapped
        case saveButtonTapped
        
        case path(StackActionOf<Path>)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case requestDismiss
            case requestSelectedTicker(Ticker)
            case requestSaveTrade(Trade)
        }
    }
    
    public init() {}
    
    @Dependency(\.tickerClient) private var tickerClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.requestDismiss))
                
            case .saveButtonTapped:
                return .send(.delegate(.requestSaveTrade(state.trade)))

            case .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
