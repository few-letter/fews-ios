//
//  StatView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture
import Charts

public struct StatNavigationView: View {
    @Bindable public var store: StoreOf<StatNavigationStore>
    
    public init(store: StoreOf<StatNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 요약 카드들
                    summaryCardsView
                    
                    // 월별 거래량 차트
                    monthlyTradeChart
                    
                    // 매수/매도 비율 차트
                    tradeSideRatioChart
                    
                    // Ticker별 거래량 차트
                    tickerTradeChart
                    
                    // Ticker 타입별 분포 차트
                    tickerTypeDistributionChart
                    
                    // 통화별 거래량 차트
                    currencyTradeChart
                    
                    // 일별 거래량 추이
                    dailyVolumeChart
                    
                    // 수수료 분석
                    feeAnalysisChart
                }
                .padding()
            }
            .navigationTitle("통계")
            .refreshable {
                store.send(.onAppear)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    // MARK: - Summary Cards
    private var summaryCardsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            SummaryCard(
                title: "총 거래 금액",
                value: formatCurrency(totalAmount),
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
            
            SummaryCard(
                title: "총 거래 수",
                value: "\(store.trades.count)회",
                icon: "number.circle",
                color: .orange
            )
            
            SummaryCard(
                title: "총 수수료",
                value: formatCurrency(totalFees),
                icon: "minus.circle",
                color: .red
            )
            
            SummaryCard(
                title: "평균 거래액",
                value: formatCurrency(store.trades.isEmpty ? 0 : totalAmount / Double(store.trades.count)),
                icon: "chart.bar.fill",
                color: .green
            )
            
            SummaryCard(
                title: "활성 종목 수",
                value: "\(activeTickers.count)개",
                icon: "building.2.fill",
                color: .purple
            )
            
            SummaryCard(
                title: "수수료율",
                value: String(format: "%.2f%%", totalAmount > 0 ? (totalFees / totalAmount) * 100 : 0),
                icon: "percent",
                color: .pink
            )
        }
    }
    
    // MARK: - Monthly Trade Chart
    private var monthlyTradeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("월별 거래량")
                .font(.headline)
                .padding(.horizontal)
            
            if !monthlyData.isEmpty {
                Chart(monthlyData, id: \.month) { data in
                    BarMark(
                        x: .value("월", data.month),
                        y: .value("거래량", data.totalAmount)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(8)
                }
                .frame(height: 200)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "거래 데이터가 없습니다")
            }
        }
    }
    
    // MARK: - Trade Side Ratio Chart
    private var tradeSideRatioChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("매수/매도 비율")
                .font(.headline)
                .padding(.horizontal)
            
            if !sideStatistics.isEmpty {
                Chart(sideStatistics, id: \.side) { data in
                    SectorMark(
                        angle: .value("거래량", data.totalAmount),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(data.side.color.gradient)
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "거래 데이터가 없습니다")
            }
        }
    }
    
    // MARK: - Ticker Trade Chart
    private var tickerTradeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종목별 거래량")
                .font(.headline)
                .padding(.horizontal)
            
            if !tickerTradeData.isEmpty {
                Chart(tickerTradeData, id: \.tickerName) { data in
                    BarMark(
                        x: .value("종목", data.tickerName),
                        y: .value("거래량", data.totalAmount)
                    )
                    .foregroundStyle(.green.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "종목별 거래 데이터가 없습니다")
            }
        }
    }
    
    // MARK: - Ticker Type Distribution Chart
    private var tickerTypeDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종목 타입별 분포")
                .font(.headline)
                .padding(.horizontal)
            
            if !tickerTypeData.isEmpty {
                Chart(tickerTypeData, id: \.type.rawValue) { data in
                    SectorMark(
                        angle: .value("개수", data.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(data.color.gradient)
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "종목 타입 데이터가 없습니다")
            }
        }
    }
    
    // MARK: - Currency Trade Chart
    private var currencyTradeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("통화별 거래량")
                .font(.headline)
                .padding(.horizontal)
            
            if !currencyTradeData.isEmpty {
                Chart(currencyTradeData, id: \.currency.rawValue) { data in
                    BarMark(
                        x: .value("통화", data.currencyName),
                        y: .value("거래량", data.totalAmount)
                    )
                    .foregroundStyle(data.color.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 180)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "통화별 거래 데이터가 없습니다")
            }
        }
    }
    
    // MARK: - Daily Volume Chart
    private var dailyVolumeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("일별 거래량 추이")
                .font(.headline)
                .padding(.horizontal)
            
            if !dailyVolume.isEmpty {
                Chart(dailyVolume, id: \.date) { data in
                    LineMark(
                        x: .value("날짜", data.date),
                        y: .value("거래량", data.volume)
                    )
                    .foregroundStyle(.purple.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("날짜", data.date),
                        y: .value("거래량", data.volume)
                    )
                    .foregroundStyle(.purple.gradient.opacity(0.3))
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, dailyVolume.count / 5))) { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "일별 거래 데이터가 없습니다")
            }
        }
    }
    
    // MARK: - Fee Analysis Chart
    private var feeAnalysisChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("월별 수수료 분석")
                .font(.headline)
                .padding(.horizontal)
            
            let monthlyFees = calculateMonthlyFees()
            
            if !monthlyFees.isEmpty {
                Chart(monthlyFees, id: \.month) { data in
                    RectangleMark(
                        x: .value("월", data.month),
                        y: .value("수수료", data.totalFee)
                    )
                    .foregroundStyle(.red.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 150)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyChartView(message: "수수료 데이터가 없습니다")
            }
        }
    }
}

// MARK: - Computed Properties (View Logic)
extension StatNavigationView {
    private var activeTickers: [Ticker] {
        let tradeTickerIds = Set(store.trades.compactMap { $0.ticker?.id })
        return store.tickers.filter { tradeTickerIds.contains($0.id) }
    }
    
    private var totalAmount: Double {
        store.trades.reduce(0) { $0 + ($1.price * $1.quantity) }
    }
    
    private var totalFees: Double {
        store.trades.reduce(0) { $0 + $1.fee }
    }
    
    private var monthlyData: [MonthlyTradeSummary] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        let grouped = Dictionary(grouping: store.trades) { trade in
            calendar.startOfMonth(for: trade.date)
        }
        
        return grouped.map { (date, trades) in
            let buyTrades = trades.filter { $0.side == .buy }
            let sellTrades = trades.filter { $0.side == .sell }
            
            return MonthlyTradeSummary(
                month: formatter.string(from: date),
                totalAmount: trades.reduce(0) { $0 + ($1.price * $1.quantity) },
                tradeCount: trades.count,
                buyAmount: buyTrades.reduce(0) { $0 + ($1.price * $1.quantity) },
                sellAmount: sellTrades.reduce(0) { $0 + ($1.price * $1.quantity) }
            )
        }.sorted {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            let date1 = dateFormatter.date(from: $0.month) ?? Date()
            let date2 = dateFormatter.date(from: $1.month) ?? Date()
            return date1 < date2
        }
    }
    
    private var sideStatistics: [TradeSideStatistic] {
        let grouped = Dictionary(grouping: store.trades) { $0.side }
        return grouped.map { (side, trades) in
            TradeSideStatistic(
                side: side,
                count: trades.count,
                totalAmount: trades.reduce(0) { $0 + ($1.price * $1.quantity) }
            )
        }
    }
    
    private var tickerTradeData: [TickerTradeData] {
        let grouped = Dictionary(grouping: store.trades) { trade in
            trade.ticker?.name ?? "Unknown"
        }
        
        return grouped.compactMap { (tickerName, trades) -> TickerTradeData? in
            guard !trades.isEmpty else { return nil }
            
            return TickerTradeData(
                tickerName: tickerName,
                totalAmount: trades.reduce(0) { $0 + ($1.price * $1.quantity) },
                tradeCount: trades.count,
                averagePrice: trades.reduce(0) { $0 + $1.price } / Double(trades.count)
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
            .prefix(10) // 상위 10개만 표시
            .map { $0 }
    }
    
    private var tickerTypeData: [TickerTypeData] {
        let grouped = Dictionary(grouping: store.tickers) { $0.type }
        return grouped.map { (type, tickers) in
            TickerTypeData(
                type: type,
                count: tickers.count,
                color: colorForTickerType(type)
            )
        }
    }
    
    private var currencyTradeData: [CurrencyTradeData] {
        let tradesWithCurrency = store.trades.compactMap { trade -> (Trade, Currency)? in
            guard let ticker = trade.ticker else { return nil }
            return (trade, ticker.currency)
        }
        
        let grouped = Dictionary(grouping: tradesWithCurrency) { $0.1 }
        
        return grouped.map { (currency, tradeData) in
            let trades = tradeData.map { $0.0 }
            return CurrencyTradeData(
                currency: currency,
                currencyName: currencyDisplayName(currency),
                totalAmount: trades.reduce(0) { $0 + ($1.price * $1.quantity) },
                tradeCount: trades.count,
                color: colorForCurrency(currency)
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private var dailyVolume: [DailyTradeVolume] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: store.trades) { trade in
            calendar.startOfDay(for: trade.date)
        }
        
        return grouped.map { (date, trades) in
            DailyTradeVolume(
                date: date,
                volume: trades.reduce(0) { $0 + ($1.price * $1.quantity) },
                tradeCount: trades.count
            )
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Functions
    private func colorForTickerType(_ type: TickerType) -> Color {
        switch type {
        case .stock: return .blue
        // 다른 타입들도 추가 가능
        default: return .gray
        }
    }
    
    private func colorForCurrency(_ currency: Currency) -> Color {
        switch currency {
        case .dollar: return .green
        // 다른 통화들도 추가 가능
        default: return .orange
        }
    }
    
    private func currencyDisplayName(_ currency: Currency) -> String {
        switch currency {
        case .dollar: return "USD"
        // 다른 통화들도 추가 가능
        default: return currency.rawValue.uppercased()
        }
    }
    
    private func calculateMonthlyFees() -> [(month: String, totalFee: Double)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        let grouped = Dictionary(grouping: store.trades) { trade in
            calendar.startOfMonth(for: trade.date)
        }
        
        return grouped.map { (date, trades) in
            (month: formatter.string(from: date),
             totalFee: trades.reduce(0) { $0 + $1.fee })
        }.sorted { $0.month < $1.month }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KRW"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

// MARK: - Data Models
struct MonthlyTradeSummary {
    let month: String
    let totalAmount: Double
    let tradeCount: Int
    let buyAmount: Double
    let sellAmount: Double
}

struct TradeSideStatistic {
    let side: TradeSide
    let count: Int
    let totalAmount: Double
}

struct DailyTradeVolume {
    let date: Date
    let volume: Double
    let tradeCount: Int
}

struct TickerTradeData {
    let tickerName: String
    let totalAmount: Double
    let tradeCount: Int
    let averagePrice: Double
}

struct TickerTypeData {
    let type: TickerType
    let count: Int
    let color: Color
}

struct CurrencyTradeData {
    let currency: Currency
    let currencyName: String
    let totalAmount: Double
    let tradeCount: Int
    let color: Color
}

// MARK: - Supporting Views
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

