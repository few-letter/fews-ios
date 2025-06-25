//
//  TradeCellView.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import SwiftUI

public struct TradeCellView: View {
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
    
    // 이미지 표시를 위한 computed property
    private var tradeImages: [UIImage] {
        return trade.images.compactMap { UIImage(from: $0) }
    }
    
    public init(trade: TradeModel) {
        self.trade = trade
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Trade type icon
            Image(systemName: trade.side == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(trade.side == .buy ? .green : .red)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
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
                
                // Second line: Quantity · Price · Fee · Date
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
                    
                    Spacer()
                }
                
                // Third line: Images + Note (compact)
                if !tradeImages.isEmpty || !trade.note.isEmpty {
                    HStack(spacing: 6) {
                        // 이미지 표시 (최대 3개, 작은 썸네일)
                        if !tradeImages.isEmpty {
                            HStack(spacing: 2) {
                                ForEach(Array(tradeImages.prefix(3).enumerated()), id: \.offset) { index, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 16, height: 16)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                                        )
                                }
                                
                                if tradeImages.count > 3 {
                                    Text("+\(tradeImages.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 2)
                                }
                            }
                        }
                        
                        // 노트 표시 (한 줄, 축약)
                        if !trade.note.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                
                                Text(trade.note)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 4)
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

