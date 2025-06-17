//
//  ChartPeriod.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

public enum ChartPeriod: CaseIterable {
    case daily, monthly, yearly
    
    var displayText: String {
        switch self {
        case .daily: return "Daily"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}
