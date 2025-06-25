//
//  HoldingChartView.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import SwiftUI
import Charts

// MARK: - 모델 정의

/// 보유 현황 데이터
public struct HoldingData: Identifiable {
    public let id = UUID()
    public let ticker: String
    public let quantity: Double
    public let averagePrice: Double
    public let totalValue: Double
    
    public init(ticker: String, quantity: Double, averagePrice: Double, totalValue: Double) {
        self.ticker = ticker
        self.quantity = quantity
        self.averagePrice = averagePrice
        self.totalValue = totalValue
    }
    
    // 편의 계산 속성
    public var profitLoss: Double { totalValue - (averagePrice * quantity) }
    public var profitLossPercentage: Double {
        guard averagePrice > 0 else { return 0 }
        return (profitLoss / (averagePrice * quantity)) * 100
    }
}

// MARK: - 메인 차트 뷰

public struct HoldingsChartView: View {
    private let trades: [TradeModel]
    private let showLegend: Bool
    private let maxLegendItems: Int
    
    /// 초기화
    /// - Parameters:
    ///   - trades: 거래 데이터 배열
    ///   - title: 차트 제목 (기본값: "Current Holdings by Ticker")
    ///   - showLegend: 범례 표시 여부 (기본값: true)
    ///   - maxLegendItems: 범례에 표시할 최대 항목 수 (기본값: 9)
    public init(
        trades: [TradeModel],
        showLegend: Bool = true,
        maxLegendItems: Int = 9
    ) {
        self.trades = trades
        self.showLegend = showLegend
        self.maxLegendItems = maxLegendItems
    }
    
    // 보유 현황 데이터 계산
    private var holdingsData: [HoldingData] {
        calculateHoldings()
    }
    
    public var body: some View {
        Group {
            if !holdingsData.isEmpty {
                VStack {
                    // 파이 차트
                    Chart {
                        ForEach(holdingsData, id: \.ticker) { holding in
                            SectorMark(
                                angle: .value("Value", holding.totalValue),
                                innerRadius: .ratio(0.4),
                                angularInset: 1
                            )
                            .foregroundStyle(colorForTicker(holding.ticker))
                            .opacity(0.8)
                        }
                    }
                    .frame(height: 250)
                    .chartLegend(.hidden)
                    
                    // 범례 (선택사항)
                    if showLegend {
                        legendView
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                EmptyHoldingsView()
            }
        }
    }
    
    // MARK: - Private 함수들
    
    /// 거래 데이터를 기반으로 현재 보유 현황을 계산
    private func calculateHoldings() -> [HoldingData] {
        guard !trades.isEmpty else { return [] }
        
        // ticker가 있는 거래만 필터링 후 ticker ID별로 그룹화
        let validTrades = trades.compactMap { trade -> (TradeModel, TickerModel)? in
            guard let ticker = trade.ticker else { return nil }
            return (trade, ticker)
        }
        
        let groupedByTicker = Dictionary(grouping: validTrades) { $0.1.id }
        
        return groupedByTicker.compactMap { (tickerId, tradesWithTicker) in
            var totalQuantity: Double = 0
            var totalCost: Double = 0
            
            guard let ticker = tradesWithTicker.first?.1 else { return nil }
            
            // 각 거래별로 수량과 비용 계산
            for (trade, _) in tradesWithTicker {
                let quantity = trade.side == .buy ? trade.quantity : -trade.quantity
                let cost = trade.price * trade.quantity
                
                totalQuantity += quantity
                totalCost += trade.side == .buy ? cost : -cost
            }
            
            // 보유 수량이 0 이하면 제외
            guard totalQuantity > 0 else { return nil }
            
            let averagePrice = totalCost / totalQuantity
            let currentValue = totalQuantity * averagePrice
            
            return HoldingData(
                ticker: ticker.name,
                quantity: totalQuantity,
                averagePrice: averagePrice,
                totalValue: currentValue
            )
        }.sorted { $0.totalValue > $1.totalValue } // 가치순으로 정렬
    }
    
    /// 티커명에 따른 색상 반환
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
    
    // MARK: - 범례 뷰
    private var legendView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
            ForEach(holdingsData.prefix(maxLegendItems), id: \.ticker) { holding in
                HStack(spacing: 6) {
                    Circle()
                        .fill(colorForTicker(holding.ticker))
                        .frame(width: 10, height: 10)
                    Text(holding.ticker)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - 빈 상태 뷰

private struct EmptyHoldingsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.system(size: 30))
                .foregroundColor(.gray)
            
            Text("No holdings data")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
