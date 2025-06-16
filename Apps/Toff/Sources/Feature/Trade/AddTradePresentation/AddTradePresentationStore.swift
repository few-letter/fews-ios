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
        @Presents public var addTrade: AddTradeStore.State? = nil
        
        public var selectedTicker: Ticker?
        public var selectedDate: Date?
        
        public init(
            selectedTicker: Ticker? = nil,
            selectedDate: Date? = nil
        ) {
            self.selectedTicker = selectedTicker
            self.selectedDate = selectedDate
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tickerNavigation(PresentationAction<TickerNavigationStore.Action>)
        case addTrade(PresentationAction<AddTradeStore.Action>)
        
        case delegate(Delegate)
        public enum Delegate {
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
                    return .none
                    
                case .requestDismiss:
                    return .none
                }

            case .addTrade(.presented(.delegate(let action))):
                return .none
                
            case .delegate, .tickerNavigation, .addTrade:
                return .none
            }
        }
        .ifLet(\.$tickerNavigation, action: \.tickerNavigation) {
            TickerNavigationStore()
        }
        .ifLet(\.$addTrade, action: \.addTrade) {
            AddTradeStore()
        }
    }
}
