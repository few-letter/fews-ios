//
//  TickerNavigation.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct TickerNavigationStore {
    @Reducer
    public enum Path {
        case addTicker(AddTickerStore)
        case addTag(AddTagStore)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        
        public var tickers: IdentifiedArrayOf<Ticker> = []
        public var selectedTickerID: TickerID?
        
        public init(
            path: StackState<Path.State> = .init(),
            selectedTickerID: TickerID?
        ) {
            self.path = path
            self.selectedTickerID = selectedTickerID
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case cancelButtonTapped
        case addButtonTapped
        case select(Ticker)
        case delete(IndexSet)
        
        case fetch
        case fetched([Ticker])
        
        case path(StackActionOf<Path>)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case requestDismiss
            case requestSelectedTicker(Ticker)
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
                return .send(.fetch)
                
            case .cancelButtonTapped:
                return .send(.delegate(.requestDismiss))
                
            case .addButtonTapped:
                let ticker: Ticker = .init()
                state.selectedTickerID = ticker.id
                state.path.append(.addTicker(.init(ticker: ticker)))
                return .none
                
            case .select(let ticker):
                state.selectedTickerID = ticker.id
                return .send(.delegate(.requestSelectedTicker(ticker)))
                
            case let .delete(indexSet):
                for index in indexSet {
                    let ticker = state.tickers.remove(at: index)
                    tickerClient.delete(ticker: ticker)
                }
                return .send(.fetch)
                
            case .fetch:
                let tickers = tickerClient.fetches()
                return .send(.fetched(tickers))
                
            case .fetched(let tickers):
                state.tickers = .init(uniqueElements: tickers)
                return .none
                
            case .path(.element(id: let id, action: .addTicker(.delegate(let action)))):
                switch action {
                case .requestSaved(let ticker):
                    let _ = tickerClient.create(ticker: ticker)
                    return .concatenate([
                        .send(.path(.popFrom(id: id))),
                        .send(.fetch)
                    ])
                }
                
            case .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
