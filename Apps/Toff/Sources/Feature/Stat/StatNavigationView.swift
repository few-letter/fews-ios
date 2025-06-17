//
//  StatView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture
import Charts

// MARK: - 공통화된 데이터 모델들

// 1. 시간 기간을 나타내는 공통 프로토콜
protocol TimePeriodRepresentable {
    var displayLabel: String { get }
    var sortKey: String { get }
}

// 2. 매매 데이터를 나타내는 공통 프로토콜
protocol TradingVolumeData {
    var buyVolume: Double { get }
    var sellVolume: Double { get }
    var buyQuantity: Double { get }
    var sellQuantity: Double { get }
}

// 3. 통합된 시간 기간 enum
enum TimePeriod: TimePeriodRepresentable {
    case daily(Date)
    case monthly(Date)
    case yearly(Int)
    case custom(String)
    
    var displayLabel: String {
        switch self {
        case .daily(let date):
            return DateFormatter.dayMonth.string(from: date)
        case .monthly(let date):
            return DateFormatter.monthOnly.string(from: date)
        case .yearly(let year):
            return String(year)
        case .custom(let label):
            return label
        }
    }
    
    var sortKey: String {
        switch self {
        case .daily(let date):
            return DateFormatter.sortable.string(from: date)
        case .monthly(let date):
            return DateFormatter.yearMonth.string(from: date)
        case .yearly(let year):
            return String(year)
        case .custom(let label):
            return label
        }
    }
}

// 4. 통합된 매매 볼륨 데이터 구조체
struct UnifiedTradingVolume: TradingVolumeData, Identifiable {
    let id = UUID()
    let period: TimePeriod
    let buyVolume: Double
    let sellVolume: Double
    let buyQuantity: Double
    let sellQuantity: Double
    
    // 편의 계산 속성들
    var totalVolume: Double { buyVolume + sellVolume }
    var totalQuantity: Double { buyQuantity + sellQuantity }
    var netVolume: Double { buyVolume - sellVolume }
    var netQuantity: Double { buyQuantity - sellQuantity }
    
    // 차트용 데이터로 변환
    var asChartData: BuySellVolumeData {
        BuySellVolumeData(
            label: period.displayLabel,
            buyVolume: buyVolume,
            sellVolume: sellVolume
        )
    }
    
    // 매매 비율 계산
    var buyRatio: Double {
        guard totalVolume > 0 else { return 0 }
        return buyVolume / totalVolume
    }
    
    var sellRatio: Double {
        guard totalVolume > 0 else { return 0 }
        return sellVolume / totalVolume
    }
    
    // 특정 기간의 데이터만 필터링
    static func filterByDateRange(_ data: [UnifiedTradingVolume], from startDate: Date, to endDate: Date) -> [UnifiedTradingVolume] {
        return data.filter { volume in
            switch volume.period {
            case .daily(let date), .monthly(let date):
                return date >= startDate && date <= endDate
            case .yearly(let year):
                let yearDate = Calendar.current.date(from: DateComponents(year: year)) ?? Date()
                return yearDate >= startDate && yearDate <= endDate
            case .custom:
                return true // 커스텀은 항상 포함
            }
        }
    }
}

// 5. 차트 표시용 간소화된 구조체
struct BuySellVolumeData: Identifiable {
    let id = UUID()
    let label: String
    let buyVolume: Double
    let sellVolume: Double
}

// 7. 차트 기간 설정
enum ChartPeriod: CaseIterable {
    case daily, monthly, yearly
    
    var displayText: String {
        switch self {
        case .daily: return "Daily"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// 8. 트렌드 방향
enum TrendDirection {
    case up, down, neutral
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .neutral: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "minus"
        }
    }
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
    
    static let monthOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    static let yearMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    static let sortable: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - 데이터 변환 헬퍼 클래스
class TradingDataConverter {
    static func convertToUnifiedVolume(
        from trades: [TradeModel],
        period: ChartPeriod
    ) -> [UnifiedTradingVolume] {
        let calendar = Calendar.current
        
        let grouped: [String: [TradeModel]]
        
        switch period {
        case .daily:
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let recentTrades = trades.filter { $0.date >= sevenDaysAgo }
            grouped = Dictionary(grouping: recentTrades) { trade in
                DateFormatter.sortable.string(from: calendar.startOfDay(for: trade.date))
            }
            
        case .monthly:
            grouped = Dictionary(grouping: trades) { trade in
                DateFormatter.yearMonth.string(from: calendar.startOfMonth(for: trade.date))
            }
            
        case .yearly:
            grouped = Dictionary(grouping: trades) { trade in
                String(calendar.component(.year, from: trade.date))
            }
        }
        
        return grouped.compactMap { (key, trades) in
            let (buyVolume, sellVolume, buyQuantity, sellQuantity) = calculateVolumes(trades)
            
            let timePeriod: TimePeriod
            switch period {
            case .daily:
                if let date = DateFormatter.sortable.date(from: key) {
                    timePeriod = .daily(date)
                } else {
                    return nil
                }
            case .monthly:
                if let date = DateFormatter.yearMonth.date(from: key) {
                    timePeriod = .monthly(date)
                } else {
                    return nil
                }
            case .yearly:
                if let year = Int(key) {
                    timePeriod = .yearly(year)
                } else {
                    return nil
                }
            }
            
            return UnifiedTradingVolume(
                period: timePeriod,
                buyVolume: buyVolume,
                sellVolume: sellVolume,
                buyQuantity: buyQuantity,
                sellQuantity: sellQuantity
            )
        }.sorted { $0.period.sortKey < $1.period.sortKey }
    }
    
    private static func calculateVolumes(_ trades: [TradeModel]) -> (Double, Double, Double, Double) {
        let buyTrades = trades.filter { $0.side == .buy }
        let sellTrades = trades.filter { $0.side == .sell }
        
        let buyVolume = buyTrades.reduce(0) { $0 + ($1.price * $1.quantity) }
        let sellVolume = sellTrades.reduce(0) { $0 + ($1.price * $1.quantity) }
        let buyQuantity = buyTrades.reduce(0) { $0 + $1.quantity }
        let sellQuantity = sellTrades.reduce(0) { $0 + $1.quantity }
        
        return (buyVolume, sellVolume, buyQuantity, sellQuantity)
    }
}

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
    
    // MARK: - Summary Cards (개선된 버전)
    private var summaryCardsView: some View {
        HStack(spacing: 8) {
            CompactSummaryCard(
                title: "Total Volume",
                value: formatCurrency(unifiedVolumeData.reduce(0) { $0 + $1.totalVolume }),
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
            
            CompactSummaryCard(
                title: "Net Volume",
                value: formatCurrency(unifiedVolumeData.reduce(0) { $0 + $1.netVolume }),
                icon: "plusminus.circle",
                color: unifiedVolumeData.reduce(0) { $0 + $1.netVolume } >= 0 ? .green : .red
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Holdings by Ticker")
                .font(.headline)
                .padding(.horizontal)
            
            Group {
                if !store.trades.isEmpty {
                    HoldingsChartView(trades: store.trades)
                } else {
                    EmptyChartView(message: "No holdings data")
                }
            }
        }
    }
    
    // MARK: - Volume Chart
    private var volumeChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trading Volume")
                .font(.headline)
                .padding(.horizontal)
            
            Group {
                if let chartData = getVolumeData() {
                    createVolumeChart(data: chartData)
                } else {
                    EmptyChartView(message: "No trading data")
                }
            }
        }
    }
}

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
    
    // 통합된 볼륨 데이터
    private var unifiedVolumeData: [UnifiedTradingVolume] {
        TradingDataConverter.convertToUnifiedVolume(
            from: filteredTrades,
            period: selectedPeriod
        )
    }
    
    // 차트용 데이터 - 이제 한 줄로!
    private func getVolumeData() -> [BuySellVolumeData]? {
        guard !unifiedVolumeData.isEmpty else { return nil }
        return unifiedVolumeData.map { $0.asChartData }
    }
    
    // 통합된 차트 생성
    @ViewBuilder
    private func createVolumeChart(data: [BuySellVolumeData]) -> some View {
        Chart {
            ForEach(data) { item in
                if selectedPeriod == .daily {
                    // Daily: Area + Line Chart
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
                    // Monthly/Yearly: Bar Chart
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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // 종목별 색상 함수
    private func colorForTicker(_ tickerName: String) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .red, .pink,
            .yellow, .indigo, .mint, .cyan, .teal, .brown,
            Color(red: 0.2, green: 0.6, blue: 0.9),
            Color(red: 0.9, green: 0.3, blue: 0.5),
            Color(red: 0.6, green: 0.8, blue: 0.3),
            Color(red: 0.8, green: 0.5, blue: 0.9),
            Color(red: 0.9, green: 0.7, blue: 0.2),
            Color(red: 0.3, green: 0.7, blue: 0.7)
        ]
        
        let index = abs(tickerName.hashValue) % colors.count
        return colors[index]
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency?.rawValue ?? "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 30))
                .foregroundColor(.gray)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
