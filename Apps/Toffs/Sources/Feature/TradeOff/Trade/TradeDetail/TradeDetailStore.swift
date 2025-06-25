//
//  TradeDetailStore.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import ComposableArchitecture

import UIKit

@Reducer
public struct TradeDetailStore {
    @ObservableState
    public struct State {
        public let trade: TradeModel
        public var isLoading: Bool = false
        public var isShowingImageDetail: Bool = false
        public var selectedImageIndex: Int = 0
        
        @Presents public var addTickerNavigation: AddTickerNavigationStore.State? = nil
        @Presents public var addTradeNavigation: AddTradeNavigationStore.State? = nil
        
        // 거래 이미지 배열
        public var tradeImages: [UIImage] {
            trade.images.compactMap { UIImage(from: $0) }
        }
        
        // 거래 총 금액
        public var totalAmount: Double {
            trade.price * trade.quantity
        }
        
        // 수수료 포함 총 금액
        public var totalAmountWithFee: Double {
            totalAmount + trade.fee
        }
        
        public init(trade: TradeModel) {
            self.trade = trade
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case refresh
        
        case editTradeButtonTapped
        case deleteTradeButtonTapped
        case showImageDetail(Int)
        case hideImageDetail
        
        case addTickerNavigation(PresentationAction<AddTickerNavigationStore.Action>)
        case addTradeNavigation(PresentationAction<AddTradeNavigationStore.Action>)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case requestDismiss
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
                
            case .refresh:
                return .none
                
            case .editTradeButtonTapped:
                if let ticker = state.trade.ticker {
                    state.addTradeNavigation = .init(addTradeType: .edit(trade: state.trade))
                }
                return .none
                
            case .deleteTradeButtonTapped:
                let _ = tradeClient.delete(trade: state.trade)
                return .send(.delegate(.requestDismiss))
                
            case .showImageDetail(let index):
                state.selectedImageIndex = index
                state.isShowingImageDetail = true
                return .none
                
            case .hideImageDetail:
                state.isShowingImageDetail = false
                return .none
                
            case .addTickerNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestDismiss:
                    state.addTickerNavigation = nil
                    return .none
                case .requestSelectedTicker:
                    state.addTickerNavigation = nil
                    return .none
                }
                
            case .addTradeNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestDismiss:
                    state.addTradeNavigation = nil
                    return .none
                case .requestSaved:
                    state.addTradeNavigation = nil
                    return .send(.delegate(.requestDismiss))
                }
                
            case .addTickerNavigation, .addTradeNavigation, .delegate:
                return .none
            }
        }
        .ifLet(\.$addTickerNavigation, action: \.addTickerNavigation) {
            AddTickerNavigationStore()
        }
        .ifLet(\.$addTradeNavigation, action: \.addTradeNavigation) {
            AddTradeNavigationStore()
        }
    }
}
