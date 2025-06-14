//
//  AddTradeStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct AddTradeStore {
    @ObservableState
    struct State: Equatable {
        var trade: Trade = Trade(
            id: UUID(),
            side: .buy,
            price: 0,
            quantity: 0,
            fee: 0,
            images: [],
            note: "",
            date: Date.now,
            ticker: nil
        )
        var availableTickers: [Ticker] = []
        
        // UI용 텍스트 필드들
        var priceText: String = ""
        var quantityText: String = ""
        var feeText: String = ""
        
        var isFormValid: Bool {
            !priceText.isEmpty &&
            !quantityText.isEmpty &&
            Double(priceText) != nil &&
            Double(quantityText) != nil &&
            trade.ticker != nil
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case imageAdded(Data)
        case imageRemoved(IndexSet)
        case saveButtonTapped
        case cancelButtonTapped
        case tradeSaved
        case loadTickersResponse([Ticker])
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.priceText):
                if let price = Double(state.priceText) {
                    state.trade.price = price
                }
                return .none
                
            case .binding(\.quantityText):
                if let quantity = Double(state.quantityText) {
                    state.trade.quantity = quantity
                }
                return .none
                
            case .binding(\.feeText):
                if let fee = Double(state.feeText) {
                    state.trade.fee = fee
                }
                return .none
                
            case .binding:
                return .none
                
            case .onAppear:
                return .run { send in
                    // Load available tickers
                    // This would typically come from a repository or service
                    let tickers: [Ticker] = [] // Load from your data source
                    await send(.loadTickersResponse(tickers))
                }
                
            case let .imageAdded(imageData):
                state.trade.images.append(imageData)
                return .none
                
            case let .imageRemoved(indexSet):
                state.trade.images.remove(atOffsets: indexSet)
                return .none
                
            case .saveButtonTapped:
                guard state.isFormValid else { return .none }
                
                return .run { [trade = state.trade] send in
                    // Trade 모델을 그대로 사용
                    // Save to SwiftData context
                    // This would typically be handled by a repository
                    
                    await send(.tradeSaved)
                }
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .tradeSaved:
                return .run { _ in await dismiss() }
                
            case let .loadTickersResponse(tickers):
                state.availableTickers = tickers
                return .none
            }
        }
    }
}
