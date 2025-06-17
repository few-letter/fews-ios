//
//  TradeSide.swift
//  ToolinderDomainTradeInterface
//
//  Created by 송영모 on 2023/09/04.
//

import SwiftUI

public enum TradeSide: String, Codable, CaseIterable {
    case buy = "Buy"
    case sell = "Sell"
}

extension TradeSide {
    public var displayText: String {
        switch self {
        case .buy: return "Buy"
        case .sell: return "Sell"
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .buy: return "arrow.up.circle"
        case .sell: return "arrow.down.circle"
        }
    }
    
    public var color: Color {
        switch self {
        case .buy: return .green
        case .sell: return .red
        }
    }
}
