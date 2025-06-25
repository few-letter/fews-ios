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
        public var ticker: TickerModel
        public var tags: IdentifiedArrayOf<Tag> = []
        
        public init(ticker: TickerModel) {
            self.ticker = ticker
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case saveButtonTapped
        
        case fetch
        case fetched([Tag])
        
        case delegate(Delegate)
        public enum Delegate {
            case saved(TickerModel)
        }
    }
    
    @Dependency(\.tickerClient) private var tickerClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
            case .saveButtonTapped:
                let _ = tickerClient.createOrUpdate(ticker: state.ticker)
                return .send(.delegate(.saved(state.ticker)))
                
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
