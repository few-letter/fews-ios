//
//  TradeType.swift
//  ToolinderDomainTradeInterface
//
//  Created by 송영모 on 2023/09/04.
//

import Foundation

public enum TickerType: String, Codable, CaseIterable {
    case stock = "Stock"
    case crypto = "Crypto"
    case gold = "Gold"
    case realEstate = "Real Estate"
}

extension TickerType {
    public var displayText: String {
        switch self {
        case .stock:
            return "Stock"
        case .crypto:
            return "Crypto"
        case .gold:
            return "Gold"
        case .realEstate:
            return "Real Estate"
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .stock:
            return "chart.line.uptrend.xyaxis"
        case .crypto:
            return "bitcoinsign.circle"
        case .gold:
            return "sparkles"
        case .realEstate:
            return "house.fill"
        }
    }
}
