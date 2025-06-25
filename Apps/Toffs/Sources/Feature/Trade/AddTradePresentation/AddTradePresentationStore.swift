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
        @Presents public var addTradeNavigation: AddTradeNavigationStore.State? = nil
        
        public var selectedDate: Date = .now
        public var selectedTicker: Ticker?
        
        public init() { }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tickerNavigation(PresentationAction<TickerNavigationStore.Action>)
        case addTradeNavigation(PresentationAction<AddTradeNavigationStore.Action>)
        
        case delegate(Delegate)
        
        public enum Delegate {
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
                state.tickerNavigation = nil
                
                switch action {
                case .requestSelectedTicker(let ticker):
                    state.selectedTicker = ticker
                    state.addTradeNavigation = .init(addTradeType: .new(ticker: ticker, selectedDate: state.selectedDate))
                    return .none
                    
                case .requestDismiss:
                    return .none
                }
                
            case .addTradeNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestDismiss:
                    state.addTradeNavigation = nil
                    return .send(.delegate(.dismiss))
                    
                case .requestSaved:
                    state.addTradeNavigation = nil
                    return .send(.delegate(.dismiss))
                }
                
            case .tickerNavigation, .addTradeNavigation, .delegate:
                return .none
            }
        }
        .ifLet(\.$tickerNavigation, action: \.tickerNavigation) {
            TickerNavigationStore()
        }
        .ifLet(\.$addTradeNavigation, action: \.addTradeNavigation) {
            AddTradeNavigationStore()
        }
    }
}
