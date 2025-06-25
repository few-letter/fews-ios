//
//  AddTrade.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddTradeOffOverlayStore {
    @ObservableState
    public struct State {
        @Presents public var addTickerNavigation: AddTickerNavigationStore.State? = nil
        @Presents public var addTradeNavigation: AddTradeNavigationStore.State? = nil
        
        public var selectedDate: Date = .now
        public var selectedTicker: TickerModel?
        
        public init() { }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case addTickerNavigation(PresentationAction<AddTickerNavigationStore.Action>)
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
                
            case .addTickerNavigation(.presented(.delegate(let action))):
                state.addTickerNavigation = nil
                
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
                
            case .addTickerNavigation, .addTradeNavigation, .delegate:
                return .none
            }
        }
        .ifLet(\.$addTickerNavigation, action: \.addTickerNavigation) {
            AddTickerNavigationStore()
        }
        .ifLet(\.$addTradeNavigation, action: \.addTradeNavigation) {
            AddTradeNavigationStore()
        }
    }
}
