//
//  AddTradeNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddTradePresentationView: View {
    @Bindable var store: StoreOf<AddTradePresentationStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension AddTradePresentationView {
    private var mainView: some View {
        Color.clear
            .sheet(item: $store.scope(state: \.tickerNavigation, action: \.tickerNavigation)) { store in
                TickerNavigationView(store: store)
            }
            .sheet(item: $store.scope(state: \.tradeNavigation, action: \.tradeNavigation)) { store in
                TradeNavigationView(store: store)
            }
        
    }
}
