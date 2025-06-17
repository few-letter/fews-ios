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
        public let originalTrade: Trade? // 원본 Trade (수정 모드일 때만 존재)
        public var temporaryTrade: Trade // 임시 복사본
        public var trades: [Trade] = []
        
        public var isFormValid: Bool {
            temporaryTrade.price > 0 && temporaryTrade.quantity > 0
        }
        
        public init(
            path: StackState<Path.State> = .init(),
            ticker: Ticker,
            trade: Trade? = nil
        ) {
            self.path = path
            self.ticker = ticker
            self.originalTrade = trade
            
            if let trade {
                // 기존 Trade를 수정하는 경우: 복사본 생성
                self.temporaryTrade = trade.copy()
            } else {
                // 새로운 Trade를 생성하는 경우
                self.temporaryTrade = .init(ticker: ticker)
            }
            
            // 임시 복사본은 autosave 비활성화
            self.temporaryTrade.modelContext?.autosaveEnabled = false
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([Trade])
        
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
                if let originalTrade = state.originalTrade {
                    // 기존 Trade 수정: 원본에 임시 복사본의 값을 복사
                    originalTrade.copyValues(from: state.temporaryTrade)
                    let _ = tradeClient.createOrUpdate(trade: originalTrade)
                } else {
                    // 새로운 Trade 생성: 임시 복사본을 그대로 저장
                    let _ = tradeClient.createOrUpdate(trade: state.temporaryTrade)
                }
                return .send(.delegate(.requestSaved))

            case .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
