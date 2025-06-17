//
//  TradingVolumeChartView.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import SwiftUI
import Charts

enum TimePeriod {
    case daily(Date)
    case monthly(Date)
    case yearly(Int)
    
    var displayLabel: String {
        let calendar = Calendar.current
        switch self {
        case .daily(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        case .monthly(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .yearly(let year):
            return String(year)
        }
    }
    
    var sortKey: String {
        let calendar = Calendar.current
        switch self {
        case .daily(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        case .monthly(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: date)
        case .yearly(let year):
            return String(year)
        }
    }
}

struct TradingVolumeData: Identifiable {
    let id = UUID()
    let period: TimePeriod
    let buyVolume: Double
    let sellVolume: Double
    let buyQuantity: Double
    let sellQuantity: Double
    
    var totalVolume: Double { buyVolume + sellVolume }
    var totalQuantity: Double { buyQuantity + sellQuantity }
    var netVolume: Double { buyVolume - sellVolume }
    var netQuantity: Double { buyQuantity - sellQuantity }
    
    var buyRatio: Double {
        guard totalVolume > 0 else { return 0 }
        return buyVolume / totalVolume
    }
    
    var sellRatio: Double {
        guard totalVolume > 0 else { return 0 }
        return sellVolume / totalVolume
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let buyVolume: Double
    let sellVolume: Double
}

public struct TradingVolumeChartView: View {
    private let trades: [TradeModel]
    private let period: ChartPeriod
    private let currency: Currency?
    private let title: String
    
    public init(
        trades: [TradeModel],
        period: ChartPeriod = .monthly,
        currency: Currency? = nil,
        title: String = "Trading Volume"
    ) {
        self.trades = trades
        self.period = period
        self.currency = currency
        self.title = title
    }
    
    private var volumeData: [TradingVolumeData] {
        let filteredTrades = filterTradesByCurrency()
        guard !filteredTrades.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let grouped: [String: [TradeModel]]
        
        switch period {
        case .daily:
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let recentTrades = filteredTrades.filter { $0.date >= sevenDaysAgo }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            grouped = Dictionary(grouping: recentTrades) { trade in
                formatter.string(from: calendar.startOfDay(for: trade.date))
            }
            
        case .monthly:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            grouped = Dictionary(grouping: filteredTrades) { trade in
                formatter.string(from: calendar.startOfMonth(for: trade.date))
            }
            
        case .yearly:
            grouped = Dictionary(grouping: filteredTrades) { trade in
                String(calendar.component(.year, from: trade.date))
            }
        }
        
        return grouped.compactMap { (key, trades) in
            let (buyVolume, sellVolume, buyQuantity, sellQuantity) = calculateVolumes(trades)
            
            let timePeriod: TimePeriod
            switch period {
            case .daily:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                guard let date = formatter.date(from: key) else { return nil }
                timePeriod = .daily(date)
            case .monthly:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                guard let date = formatter.date(from: key) else { return nil }
                timePeriod = .monthly(date)
            case .yearly:
                guard let year = Int(key) else { return nil }
                timePeriod = .yearly(year)
            }
            
            return TradingVolumeData(
                period: timePeriod,
                buyVolume: buyVolume,
                sellVolume: sellVolume,
                buyQuantity: buyQuantity,
                sellQuantity: sellQuantity
            )
        }.sorted { $0.period.sortKey < $1.period.sortKey }
    }
    
    private var chartData: [ChartDataPoint] {
        volumeData.map { data in
            ChartDataPoint(
                label: data.period.displayLabel,
                buyVolume: data.buyVolume,
                sellVolume: data.sellVolume
            )
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            Group {
                if !chartData.isEmpty {
                    createVolumeChart()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                } else {
                    EmptyVolumeChartView()
                }
            }
        }
    }
    
    private func filterTradesByCurrency() -> [TradeModel] {
        guard let currency = currency else { return trades }
        return trades.filter { $0.ticker?.currency == currency }
    }
    
    private func calculateVolumes(_ trades: [TradeModel]) -> (Double, Double, Double, Double) {
        let buyTrades = trades.filter { $0.side == .buy }
        let sellTrades = trades.filter { $0.side == .sell }
        
        let buyVolume = buyTrades.reduce(0) { $0 + ($1.price * $1.quantity) }
        let sellVolume = sellTrades.reduce(0) { $0 + ($1.price * $1.quantity) }
        let buyQuantity = buyTrades.reduce(0) { $0 + $1.quantity }
        let sellQuantity = sellTrades.reduce(0) { $0 + $1.quantity }
        
        return (buyVolume, sellVolume, buyQuantity, sellQuantity)
    }
    
    @ViewBuilder
    private func createVolumeChart() -> some View {
        Chart {
            ForEach(chartData) { item in
                if period == .daily {
                    AreaMark(
                        x: .value("Period", item.label),
                        y: .value("Volume", item.buyVolume)
                    )
                    .foregroundStyle(.green.gradient.opacity(0.7))
                    
                    AreaMark(
                        x: .value("Period", item.label),
                        y: .value("Volume", -item.sellVolume)
                    )
                    .foregroundStyle(.red.gradient.opacity(0.7))
                } else {
                    BarMark(
                        x: .value("Period", item.label),
                        y: .value("Volume", item.buyVolume)
                    )
                    .foregroundStyle(.green.gradient)
                    .position(by: .value("Type", "Buy"))
                    
                    BarMark(
                        x: .value("Period", item.label),
                        y: .value("Volume", item.sellVolume)
                    )
                    .foregroundStyle(.red.gradient)
                    .position(by: .value("Type", "Sell"))
                }
            }
        }
        .frame(height: 250)
        .chartYAxis {
            AxisMarks { value in
                let doubleValue = value.as(Double.self) ?? 0
                AxisValueLabel {
                    Text(formatCurrency(abs(doubleValue)))
                        .font(.caption)
                }
            }
        }
        .chartLegend(position: .top) {
            HStack {
                Label("Buy", systemImage: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                Label("Sell", systemImage: "arrow.down.circle.fill")
                    .foregroundColor(.red)
            }
            .font(.caption)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency?.rawValue ?? "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

private struct EmptyVolumeChartView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 30))
                .foregroundColor(.gray)
            
            Text("No trading data")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
