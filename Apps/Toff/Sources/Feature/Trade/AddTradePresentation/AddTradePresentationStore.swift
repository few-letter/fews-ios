//
//  AddTrade.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddTradePresentationStore {
    @ObservableState
    public struct State {
        @Presents public var tickerNavigation: TickerNavigationStore.State? = nil
        @Presents public var tradeNavigation: TradeNavigationStore.State? = nil
        
        public var selectedTicker: Ticker?
        
        public init(
            selectedTicker: Ticker? = nil
        ) {
            self.selectedTicker = selectedTicker
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tickerNavigation(PresentationAction<TickerNavigationStore.Action>)
        case tradeNavigation(PresentationAction<TradeNavigationStore.Action>)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case requestTradeNavigation(Ticker)
            case dismiss
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
                
            case .tickerNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestSelectedTicker(let ticker):
                    state.tickerNavigation = nil
                    return .send(.delegate(.requestTradeNavigation(ticker)))
                    
                case .requestDismiss:
                    state.tickerNavigation = nil
                    return .none
                }
                
            case .tradeNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestDismiss:
                    state.tradeNavigation = nil
                    return .send(.delegate(.dismiss))
                    
                case .requestSaved:
                    state.tradeNavigation = nil
                    return .send(.delegate(.dismiss))
                }
                
            case .tickerNavigation, .tradeNavigation, .delegate:
                return .none
            }
        }
        .ifLet(\.$tickerNavigation, action: \.tickerNavigation) {
            TickerNavigationStore()
        }
        .ifLet(\.$tradeNavigation, action: \.tradeNavigation) {
            TradeNavigationStore()
        }
    }
}
