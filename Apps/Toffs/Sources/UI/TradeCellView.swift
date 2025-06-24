//
//  TradePreviewView.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import SwiftUI

public struct TradeCellView: View {
    private let trade: TradeModel
    
    public init(trade: TradeModel) {
        self.trade = trade
    }
    
    public var body: some View {
        HStack {
            Image(systemName: trade.side.systemImageName)
                .foregroundColor(.black)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(trade.side.displayText)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(trade.ticker?.name ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Price: \(trade.price, format: .number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Qty: \(trade.quantity, format: .number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if trade.fee > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Fee: \(trade.fee, format: .number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(trade.date, style: .date) \(trade.date, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !trade.note.isEmpty {
                    Text(trade.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
