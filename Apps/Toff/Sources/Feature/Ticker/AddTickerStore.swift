//
//  AddTickerStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
public struct AddTickerStore {
    @ObservableState
    public struct State {
        public var ticker: Ticker
        public var tags: IdentifiedArrayOf<Tag> = []
        
        public init(ticker: Ticker) {
            self.ticker = ticker
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([Tag])
        
        case delegate(Delegate)
        public enum Delegate {
            case requestCancel
            case requestUpdated(Ticker)
        }
    }
    
    @Dependency(\.tickerClient) private var tickerClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .fetch:
                return .none
                
            case .fetched(let tags):
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
