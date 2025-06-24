//
//  TradeHistoryItemView.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import SwiftUI

public struct TradeHistoryItemView: View {
    public let trade: TradeModel
    
    // Number formatter helper
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
        trade: TradeModel
    ) {
        self.trade = trade
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Trade type icon
            Image(systemName: trade.side == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(trade.side == .buy ? .green : .red)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 1) {
                // First line: Ticker name + chip + total amount
                HStack {
                    Text(trade.ticker?.name ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    tradeSideChip
                    
                    Spacer()
                    
                    Text("\(s(totalAmount)) \(trade.ticker?.currency.displayText ?? "")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                // Second line: Quantity · Price · Fee · Date · Note
                HStack(spacing: 4) {
                    Text("\(s(trade.quantity)) · \(s(trade.price))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if trade.fee > 0 {
                        Text("· Fee \(s(trade.fee))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Text("· \(trade.date, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !trade.note.isEmpty {
                        Text("· \(trade.note)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private var tradeSideChip: some View {
        Text(trade.side == .buy ? "BUY" : "SELL")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(trade.side == .buy ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .foregroundColor(trade.side == .buy ? .green : .red)
            .cornerRadius(3)
    }
    
    private var totalAmount: Double {
        return trade.price * trade.quantity
    }
}
