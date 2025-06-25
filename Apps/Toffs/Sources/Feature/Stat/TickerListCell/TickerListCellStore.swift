////
////  TickerListCellStore.swift
////  Toff
////
////  Created by 송영모 on 6/15/25.
////
//
//import Foundation
//import ComposableArchitecture
//
//@Reducer
//public struct TickerListCellStore {
//    @ObservableState
//    public struct State: Equatable, Identifiable {
//        public let ticker: Ticker
//        
//        public var id: UUID {
//            ticker.id
//        }
//        
//        public init(ticker: Ticker) {
//            self.ticker = ticker
//        }
//    }
//    
//    public enum Action: Equatable {
//        case tapped
//        
//        case delegate(Delegate)
//        
//        public enum Delegate: Equatable {
//            case tapped
//        }
//    }
//    
//    public var body: some ReducerOf<Self> {
//        Reduce<State, Action> { state, action in
//            switch action {
//            case .tapped:
//                return .send(.delegate(.tapped))
//                
//            case .delegate:
//                return .none
//            }
//        }
//    }
//}
