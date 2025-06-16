//
//  TickerNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import Foundation

import SwiftUI
import ComposableArchitecture

public struct TickerNavigationView: View {
    @Bindable var store: StoreOf<TickerNavigationStore>
    
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
                        Button("Done") {
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

extension TickerNavigationView {
    private var mainView: some View {
        VStack {
            ForEach(store.tickers) { ticker in
                tickerItem(ticker: ticker) {
                    store.send(.select(ticker))
                }
            }
        }
    }
    
    private func tickerItem(ticker: Ticker, isSelected: Bool = false, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(ticker.name)
            Spacer()
        }
    }
}
