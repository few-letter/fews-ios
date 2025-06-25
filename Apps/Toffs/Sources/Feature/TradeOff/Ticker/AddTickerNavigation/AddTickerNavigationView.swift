//
//  TickerNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddTickerNavigationView: View {
    @Bindable var store: StoreOf<AddTickerNavigationStore>
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .navigationTitle("Select Ticker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            store.send(.cancelButtonTapped)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            store.send(.addButtonTapped)
                        }
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            switch store.case {
            case .addTag(let store):
                AddTagView(store: store)
            case .addTicker(let store):
                AddTickerView(store: store)
            }
        }
    }
}

extension AddTickerNavigationView {
    private var mainView: some View {
        List {
            ForEach(store.tickers) { ticker in
                Button {
                    store.send(.select(ticker))
                } label: {
                    TickerCellView(ticker: ticker)
                }
            }
            .onDelete { store.send(.delete($0)) }
        }
    }
    

}
