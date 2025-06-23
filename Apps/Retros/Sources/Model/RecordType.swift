//
//  RecordType.swift
//  KPT
//
//  Created by 송영모 on 3/18/24.
//

import Foundation

public enum RecordType: Int, CaseIterable {
    case keep
    case problem
    case `try`
    
    public var systemImageName: String {
        return switch self {
        case .keep:
            "checkmark.circle"
        case .problem:
            "exclamationmark.circle"
        case .try:
            "arrow.right.circle"
        }
    }
    
    public var displayText: String {
        return ""
    }
}
