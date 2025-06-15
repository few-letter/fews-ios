//
//  SelectTickerStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import SwiftData
import ComposableArchitecture

@Reducer
public struct SelectTickerStore {
    @ObservableState
    public struct State: Equatable {
        public var tickers: IdentifiedArrayOf<Ticker>
        public var selectedTickerID: Ticker.ID?
        
        public init(
            tickers: IdentifiedArrayOf<Ticker>,
            selectedTickerID: Ticker.ID?
        ) {
            self.tickers = tickers
            self.selectedTickerID = selectedTickerID
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([Ticker])
    }
    
    @Dependency(\.tickerClient) var tickerClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .send(.fetch)
                
            case .fetch:
                let tickers = tickerClient.fetches()
                return .send(.fetched(tickers))
                
            case .fetched(let tags):
                return .none
            }
        }
    }
}
