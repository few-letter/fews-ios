//
//  CalendarHomeStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

import CommonFeature

@Reducer
public struct CalendarHomeStore {
    @ObservableState
    public struct State {
        public var tradesByDate: [Date: IdentifiedArrayOf<TradeModel>]
        public var selectedDate: Date = Calendar.current.startOfDay(for: .now)
        
        public var addTradeOffOverlay: AddTradeOffOverlayStore.State = .init()
        
        public init(tradesByDate: [Date: IdentifiedArrayOf<TradeModel>] = [:]) {
            self.tradesByDate = tradesByDate
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case tap(TradeModel)
        case delete(IndexSet)
        case dateChanged(Date)
        case plusButtonTapped
        
        case fetch
        case fetched([TradeModel])
        
        case addTradeOffOverlay(AddTradeOffOverlayStore.Action)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case dismiss
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
                
            case .tap(let trade):
                state.addTradeOffOverlay.addTradeNavigation = .init(addTradeType: .edit(trade: trade))
                return .none
                
            case .delete(let indexSet):
                for index in indexSet {
                    if let trade = state.tradesByDate[state.selectedDate]?.remove(at: index) {
                        tradeClient.delete(trade: trade)
                    }
                }
                return .send(.fetch)
                
            case .dateChanged(let date):
                state.selectedDate = date
                return .none
                
            case .plusButtonTapped:
                state.addTradeOffOverlay.addTickerNavigation = .init(selectedTickerID: nil)
                return .none
                
            case .fetch:
                let trades = tradeClient.fetches(ticker: nil)
                return .send(.fetched(trades))
                
            case .fetched(let trades):
                state.tradesByDate = [:]
                trades.forEach { trade in
                    let date = Calendar.current.startOfDay(for: trade.date)
                    state.tradesByDate[date, default: []].updateOrAppend(trade)
                }
                return .none
                
            case .addTradeOffOverlay(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .send(.fetch)
                }
                
            case .delegate, .addTradeOffOverlay:
                return .none
            }
        }
        
        Scope(state: \.addTradeOffOverlay, action: \.addTradeOffOverlay) {
            AddTradeOffOverlayStore()
        }
    }
}

extension Trade: CalendarItem {
    public var displayTitle: String {
        return self.ticker?.name ?? ""
    }
}
