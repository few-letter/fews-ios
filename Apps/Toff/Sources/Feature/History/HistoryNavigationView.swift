//
//  HistoryNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import SwiftUI
import ComposableArchitecture

public struct HistoryNavigationView: View {
    @Bindable public var store: StoreOf<HistoryNavigationStore>
    
    public init(store: StoreOf<HistoryNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension HistoryNavigationView {
    private var mainView: some View {
        List {
            // Tickers section
            if !store.tickers.isEmpty {
                Section {
                    ForEach(store.tickers, id: \.id) { ticker in
                        Button {
                            store.send(.tickerTapped(ticker))
                        } label: {
                            TickerHistoryItemView(ticker: ticker)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Holdings")
                    }
                    .font(.headline)
                }
            }
            
            // Recent Trades section
            if !store.trades.isEmpty {
                Section {
                    ForEach(store.trades.prefix(10), id: \.id) { trade in
                        Button {
                            store.send(.tradeTapped(trade))
                        } label: {
                            TradeHistoryItemView(trade: trade)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Recent Trades")
                    }
                    .font(.headline)
                }
            }
            
            // Empty state view when there's no data
            if store.tickers.isEmpty && store.trades.isEmpty {
                emptyStateView
            }
        }
        .navigationTitle("Trading History")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No trading history")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start your first trade")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }
}
