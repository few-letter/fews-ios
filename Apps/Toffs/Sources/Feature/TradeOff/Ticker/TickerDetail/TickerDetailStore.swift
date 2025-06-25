//
//  TickerDetailStore.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct TickerDetailStore {
    @ObservableState
    public struct State {
        public var ticker: TickerModel
        public var trades: IdentifiedArrayOf<TradeModel> = []
        public var isLoading: Bool = false
        
        @Presents public var addTicker: AddTickerStore.State? = nil
        @Presents public var addTradeNavigation: AddTradeNavigationStore.State? = nil
        
        // 계산된 통계 프로퍼티
        public var totalTrades: Int {
            trades.count
        }
        
        public var totalVolume: Double {
            trades.reduce(0) { $0 + $1.quantity }
        }
        
        public var averagePrice: Double {
            let buyTrades = trades.filter { $0.side == .buy }
            let totalBuyAmount = buyTrades.reduce(0) { $0 + ($1.price * $1.quantity) }
            let totalBuyVolume = buyTrades.reduce(0) { $0 + $1.quantity }
            return totalBuyVolume > 0 ? totalBuyAmount / totalBuyVolume : 0
        }
        
        public var currentHolding: Double {
            trades.reduce(0) { result, trade in
                switch trade.side {
                case .buy:
                    return result + trade.quantity
                case .sell:
                    return result - trade.quantity
                }
            }
        }
        
        public var realizedPnL: Double {
            let sellTrades = trades.filter { $0.side == .sell }
            let avgBuyPrice = averagePrice
            return sellTrades.reduce(0) { result, trade in
                result + ((trade.price - avgBuyPrice) * trade.quantity)
            }
        }
        
        public var totalInvestedAmount: Double {
            trades.filter { $0.side == .buy }.reduce(0) { $0 + ($1.price * $1.quantity) }
        }
        
        public init(ticker: TickerModel) {
            self.ticker = ticker
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case refresh
        
        case fetch
        case fetched([TradeModel])
        
        case tradeTapped(TradeModel)
        case addTradeButtonTapped
        case editTickerButtonTapped
        
        case addTicker(PresentationAction<AddTickerStore.Action>)
        case addTradeNavigation(PresentationAction<AddTradeNavigationStore.Action>)
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
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                state.isLoading = true
                let trades = tradeClient.fetches(ticker: state.ticker)
                return .send(.fetched(trades))
                
            case .fetched(let trades):
                state.isLoading = false
                state.trades = IdentifiedArrayOf(uniqueElements: trades.sorted { $0.date > $1.date })
                return .none
                
            case .tradeTapped(let trade):
                state.addTradeNavigation = .init(addTradeType: .edit(trade: trade))
                return .none
                
            case .addTradeButtonTapped:
                state.addTradeNavigation = .init(addTradeType: .new(ticker: state.ticker, selectedDate: .now))
                return .none
                
            case .editTickerButtonTapped:
                state.addTicker = .init(ticker: state.ticker)
                return .none
                
            case .addTicker(.presented(.delegate(let action))):
                switch action {
                case .saved(let ticker):
                    state.addTicker = nil
                    state.ticker = ticker
                    return .none
                }
                
            case .addTradeNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestDismiss:
                    state.addTradeNavigation = nil
                    return .none
                case .requestSaved:
                    state.addTradeNavigation = nil
                    return .send(.fetch)
                }
                
            case .addTicker, .addTradeNavigation:
                return .none
            }
        }
        .ifLet(\.$addTicker, action: \.addTicker) {
            AddTickerStore()
        }
        .ifLet(\.$addTradeNavigation, action: \.addTradeNavigation) {
            AddTradeNavigationStore()
        }
    }
}

