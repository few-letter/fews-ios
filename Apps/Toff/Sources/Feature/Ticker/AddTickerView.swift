//
//  AddTickerView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

struct AddTickerView: View {
    @Bindable var store: StoreOf<AddTickerStore>
    
    var body: some View {
        NavigationView {
            mainView
                .navigationTitle("Add Ticker")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension AddTickerView {
    private var mainView: some View {
        VStack {
            Text("Add Ticker View")
        }
    }
}
