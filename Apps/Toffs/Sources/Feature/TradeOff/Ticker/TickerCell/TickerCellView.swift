//
//  TickerCellView.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import SwiftUI

public struct TickerCellView: View {
    public let ticker: TickerModel
    public let isSelected: Bool
    
    private var tradingData: TradingData {
        calculateTradingData()
    }
    
    // 포매터 헬퍼
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
    
    public init(
        ticker: TickerModel,
        isSelected: Bool = false
    ) {
        self.ticker = ticker
        self.isSelected = isSelected
    }
    
    public var body: some View {
        mainView
    }
    
    // MARK: - Main View (거래 통계 포함 통합 모드)
    private var mainView: some View {
        VStack(spacing: 8) {
            // Header Section
            HStack(alignment: .top) {
                Image(systemName: ticker.type.systemImageName)
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
                
                                 VStack(alignment: .leading, spacing: 2) {
                     Text(ticker.name.isEmpty ? "Ticker Name" : ticker.name)
                         .font(.subheadline)
                         .fontWeight(.medium)
                         .foregroundColor(ticker.name.isEmpty ? .secondary : .primary)
                    
                    HStack(spacing: 8) {
                        Text(ticker.type.displayText)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: ticker.currency.systemImageName)
                                .font(.caption2)
                            Text(ticker.currency.displayText)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(tradingData.tradeCount) trades")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if tradingData.currentHolding > 0 {
                        Text(s(tradingData.currentHolding))
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Compact Trading Statistics
            if tradingData.tradeCount > 0 {
                HStack(spacing: 0) {
                    compactStatItem(
                        title: "Avg",
                        value: s(tradingData.averagePrice),
                        color: .blue
                    )
                    
                    Divider()
                        .frame(height: 16)
                    
                    compactStatItem(
                        title: "Vol",
                        value: s(tradingData.totalVolume),
                        color: .orange
                    )
                    
                    Divider()
                        .frame(height: 16)
                    
                    compactStatItem(
                        title: "P&L",
                        value: formatPnLWithPercentage(tradingData.realizedPnL, tradingData.totalInvestedAmount),
                        color: tradingData.realizedPnL >= 0 ? .green : .red
                    )
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(isSelected ? Color.blue.opacity(0.08) : Color.clear)
        .cornerRadius(8)
    }
    
    // MARK: - Helper Views
    private func compactStatItem(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatPnLWithPercentage(_ pnl: Double, _ totalInvested: Double) -> String {
        let pnlText = "\(pnl >= 0 ? "+" : "")\(s(pnl))"
        
        if totalInvested > 0 {
            let percentage = (pnl / totalInvested) * 100
            let percentageText = s(abs(percentage))
            return "\(pnlText)(\(percentageText)%)"
        } else {
            return pnlText
        }
    }
    
    // MARK: - Trading Data Calculation
    private func calculateTradingData() -> TradingData {
        guard let trades = ticker.ticker?.trades, !trades.isEmpty else {
            return TradingData()
        }
        
        var totalBuyVolume: Double = 0
        var totalBuyAmount: Double = 0
        var totalSellVolume: Double = 0
        var totalSellAmount: Double = 0
        var currentHolding: Double = 0
        var realizedPnL: Double = 0
        
        // Calculate basic metrics
        for trade in trades {
            let amount = trade.price * trade.quantity
            
            switch trade.side {
            case .buy:
                totalBuyVolume += trade.quantity
                totalBuyAmount += amount
                currentHolding += trade.quantity
            case .sell:
                totalSellVolume += trade.quantity
                totalSellAmount += amount
                currentHolding -= trade.quantity
                
                // Simple realized P&L calculation
                let avgBuyPrice = totalBuyAmount / max(totalBuyVolume, 1)
                realizedPnL += (trade.price - avgBuyPrice) * trade.quantity
            }
        }
        
        let totalVolume = totalBuyVolume + totalSellVolume
        let averagePrice = totalBuyAmount / max(totalBuyVolume, 1)
        
        return TradingData(
            tradeCount: trades.count,
            totalVolume: totalVolume,
            averagePrice: averagePrice,
            currentHolding: max(currentHolding, 0),
            realizedPnL: realizedPnL,
            totalInvestedAmount: totalBuyAmount
        )
    }
}

// MARK: - Trading Data Model
private struct TradingData {
    let tradeCount: Int
    let totalVolume: Double
    let averagePrice: Double
    let currentHolding: Double
    let realizedPnL: Double
    let totalInvestedAmount: Double
    
    init(
        tradeCount: Int = 0,
        totalVolume: Double = 0,
        averagePrice: Double = 0,
        currentHolding: Double = 0,
        realizedPnL: Double = 0,
        totalInvestedAmount: Double = 0
    ) {
        self.tradeCount = tradeCount
        self.totalVolume = totalVolume
        self.averagePrice = averagePrice
        self.currentHolding = currentHolding
        self.realizedPnL = realizedPnL
        self.totalInvestedAmount = totalInvestedAmount
    }
}

