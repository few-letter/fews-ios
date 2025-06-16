//
//  CalendarHomeStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CalendarHomeStore {
    @ObservableState
    public struct State {
        public var tradesByDate: [Date: IdentifiedArrayOf<Trade>]
        
        public var selectedDate: Date?
        
        public var addTradePresentation: AddTradePresentationStore.State = .init()
        
        public init(tradesByDate: [Date: IdentifiedArrayOf<Trade>] = [:]) {
            self.tradesByDate = tradesByDate
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case dateChanged(Date)
        case plusButtonTapped
        
        case fetch
        case fetched([Trade])
        
        case addTradePresentation(AddTradePresentationStore.Action)
        
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
                return .none
                
            case .dateChanged(let date):
                state.selectedDate = date
                return .none
                
            case .plusButtonTapped:
                state.addTradePresentation.tickerNavigation = .init(selectedTickerID: nil)
                return .none
                
            case .fetch:
                let trades = tradeClient.fetches()
                return .send(.fetched(trades))
                
            case .fetched(let trades):
                trades.forEach { trade in
                    let date = Calendar.current.startOfDay(for: trade.date)
                    state.tradesByDate[date, default: []].updateOrAppend(trade)
                }
                return .none
                
            case .delegate, .addTradePresentation:
                return .none
            }
        }
        
        Scope(state: \.addTradePresentation, action: \.addTradePresentation) {
            AddTradePresentationStore()
        }
    }
}

extension Trade: CalendarItem {
    var displayTitle: String {
        return self.ticker?.name ?? ""
    }
}
