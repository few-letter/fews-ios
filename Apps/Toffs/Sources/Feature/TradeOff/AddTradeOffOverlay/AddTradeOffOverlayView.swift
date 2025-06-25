//
//  AddTradeNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddTradeOffOverlayView: View {
    @Bindable var store: StoreOf<AddTradeOffOverlayStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension AddTradeOffOverlayView {
    private var mainView: some View {
        Color.clear
            .sheet(item: $store.scope(state: \.addTickerNavigation, action: \.addTickerNavigation)) { store in
                AddTickerNavigationView(store: store)
            }
            .sheet(item: $store.scope(state: \.addTradeNavigation, action: \.addTradeNavigation)) { store in
                AddTradeNavigationView(store: store)
            }
        
    }
}
