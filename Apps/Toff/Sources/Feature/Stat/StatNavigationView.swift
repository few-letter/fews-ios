//
//  StatNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture
import Charts

// MARK: - Main View
public struct StatNavigationView: View {
    @Bindable public var store: StoreOf<StatNavigationStore>
    @State private var selectedPeriod: ChartPeriod = .monthly
    @State private var selectedCurrency: Currency?
    
    public init(store: StoreOf<StatNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    controlsView
                    summaryCardsView
                    holdingsPieChart
                    volumeChart
                }
                .padding()
            }
            .navigationTitle("Trading Statistics")
            .refreshable {
                store.send(.onAppear)
            }
        }
        .onAppear {
            store.send(.onAppear)
            if selectedCurrency == nil {
                selectedCurrency = availableCurrencies.first
            }
        }
    }
    
    // MARK: - Top Controls
    private var controlsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Currency")
                    .font(.headline)
                Spacer()
                Picker("Currency", selection: $selectedCurrency) {
                    ForEach(availableCurrencies, id: \.self) { currency in
                        HStack {
                            Image(systemName: currency.systemImageName)
                            Text(currency.displayText)
                        }
                        .tag(currency as Currency?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                Text("Period")
                    .font(.headline)
                Spacer()
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ChartPeriod.allCases, id: \.self) { period in
                        Text(period.displayText).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Summary Cards
    private var summaryCardsView: some View {
        HStack(spacing: 8) {
            CompactSummaryCard(
                title: "Total Volume",
                value: formatCurrency(calculateTotalVolume()),
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
            
            CompactSummaryCard(
                title: "Net Volume",
                value: formatCurrency(calculateNetVolume()),
                icon: "plusminus.circle",
                color: calculateNetVolume() >= 0 ? .green : .red
            )
            
            CompactSummaryCard(
                title: "Trades",
                value: "\(filteredTrades.count)",
                icon: "number.circle",
                color: .orange
            )
            
            CompactSummaryCard(
                title: "Tickers",
                value: "\(activeTickers.count)",
                icon: "building.2.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Holdings Pie Chart
    private var holdingsPieChart: some View {
        HoldingsChartView(trades: filteredTrades)
    }
    
    // MARK: - Volume Chart (대폭 간소화!)
    private var volumeChart: some View {
        TradingVolumeChartView(
            trades: filteredTrades,
            period: selectedPeriod,
            currency: selectedCurrency
        )
    }
}

// MARK: - Extensions
extension StatNavigationView {
    private var availableCurrencies: [Currency] {
        Array(Set(store.tickers.map { $0.currency })).sorted { $0.displayText < $1.displayText }
    }
    
    private var filteredTrades: [TradeModel] {
        guard let selectedCurrency = selectedCurrency else { return store.trades }
        return store.trades.filter { $0.ticker?.currency == selectedCurrency }
    }
    
    private var activeTickers: [Ticker] {
        let tradeTickerIds = Set(filteredTrades.compactMap { $0.ticker?.id })
        return store.tickers.filter { tradeTickerIds.contains($0.id) }
    }
    
    // 간단한 볼륨 계산 함수들
    private func calculateTotalVolume() -> Double {
        filteredTrades.reduce(0) { total, trade in
            total + (trade.price * trade.quantity)
        }
    }
    
    private func calculateNetVolume() -> Double {
        filteredTrades.reduce(0) { total, trade in
            let volume = trade.price * trade.quantity
            return total + (trade.side == .buy ? volume : -volume)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency?.rawValue ?? "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
