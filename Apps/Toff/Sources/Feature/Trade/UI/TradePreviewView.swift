//
//  TradePreviewView.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import SwiftUI

public struct TradePreviewView: View {
    let trade: Trade
    let ticker: Ticker
    
    public init(trade: Trade, ticker: Ticker) {
        self.trade = trade
        self.ticker = ticker
    }
    
    public var body: some View {
        HStack {
            Image(systemName: trade.side.systemImageName)
                .foregroundColor(.black)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trade.side.displayText)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(ticker.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Price: \(trade.price, format: .number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Qty: \(trade.quantity, format: .number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if trade.fee > 0 {
                            Text("Fee: \(trade.fee, format: .number)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(trade.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(trade.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !trade.note.isEmpty {
                            Text(trade.note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
