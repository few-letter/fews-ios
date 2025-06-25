//
//  TickerDetailView.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import SwiftUI
import ComposableArchitecture

public struct TickerDetailView: View {
    @Bindable public var store: StoreOf<TickerDetailStore>
    
    // 포매터
    private let numFmt: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.numberStyle = .decimal
        return f
    }()
    
    private func s(_ v: Double) -> String {
        numFmt.string(from: NSNumber(value: v)) ?? String(v)
    }
    
    public init(store: StoreOf<TickerDetailStore>) {
        self.store = store
    }
    
    public var body: some View {
        List {
                // Ticker 기본 정보 섹션
                Section {
                    TickerCellView(ticker: store.ticker)
                } header: {
                    Text("Ticker Information")
                }
                
                // 통계 섹션
                if store.totalTrades > 0 {
                    Section {
                        statisticsView
                    } header: {
                        Text("Trading Statistics")
                    }
                }
                
                // 거래 내역 섹션
                Section {
                    if store.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading trades...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else if store.trades.isEmpty {
                        emptyTradesView
                    } else {
                        ForEach(store.trades) { trade in
                            Button {
                                store.send(.tradeTapped(trade))
                            } label: {
                                TradeCellView(trade: trade)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Trade History")
                        Spacer()
                        if store.totalTrades > 0 {
                            Text("\(store.totalTrades) trades")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Button {
                            store.send(.addTradeButtonTapped)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
        }
        .navigationTitle(store.ticker.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.editTickerButtonTapped)
                } label: {
                    Text("Edit")
                }
            }
        }
        .refreshable {
            store.send(.refresh)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.addTicker, action: \.addTicker)) { store in
            NavigationView {
                AddTickerView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.addTradeNavigation, action: \.addTradeNavigation)) { store in
            AddTradeNavigationView(store: store)
        }
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        VStack(spacing: 12) {
            // 첫 번째 줄: 총 거래량과 평균가
            HStack(spacing: 0) {
                statisticItem(
                    title: "Total Volume",
                    value: s(store.totalVolume),
                    color: .blue
                )
                
                Divider()
                    .frame(height: 32)
                
                statisticItem(
                    title: "Average Price",
                    value: s(store.averagePrice),
                    color: .orange
                )
            }
            
            // 두 번째 줄: 현재 보유량과 손익
            HStack(spacing: 0) {
                statisticItem(
                    title: "Current Holding",
                    value: s(store.currentHolding),
                    color: store.currentHolding > 0 ? .green : .secondary
                )
                
                Divider()
                    .frame(height: 32)
                
                statisticItem(
                    title: "Realized P&L",
                    value: formatPnL(store.realizedPnL),
                    color: store.realizedPnL >= 0 ? .green : .red
                )
            }
            
            // 세 번째 줄: 총 투자금액과 수익률
            if store.totalInvestedAmount > 0 {
                HStack(spacing: 0) {
                    statisticItem(
                        title: "Total Invested",
                        value: s(store.totalInvestedAmount),
                        color: .purple
                    )
                    
                    Divider()
                        .frame(height: 32)
                    
                    statisticItem(
                        title: "Return Rate",
                        value: formatReturnRate(),
                        color: store.realizedPnL >= 0 ? .green : .red
                    )
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func statisticItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Empty Trades View
    private var emptyTradesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No trades yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start trading with \(store.ticker.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                store.send(.addTradeButtonTapped)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Trade")
                }
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    private func formatPnL(_ pnl: Double) -> String {
        let prefix = pnl >= 0 ? "+" : ""
        return "\(prefix)\(s(pnl))"
    }
    
    private func formatReturnRate() -> String {
        guard store.totalInvestedAmount > 0 else { return "0%" }
        let rate = (store.realizedPnL / store.totalInvestedAmount) * 100
        let prefix = rate >= 0 ? "+" : ""
        return "\(prefix)\(s(rate))%"
    }
}

