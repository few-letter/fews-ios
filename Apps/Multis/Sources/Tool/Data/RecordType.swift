//
//  RecordType.swift
//  KPT
//
//  Created by 송영모 on 3/18/24.
//

import Foundation
import SwiftUI

public enum RecordType: Int, CaseIterable {
    case keep
    case problem
    case `try`
    
    public var color: Color {
        switch self {
        case .keep:
            return .green
        case .problem:
            return .red
        case .try:
            return .blue
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .keep:
            return "checkmark.circle.fill"
        case .problem:
            return "exclamationmark.triangle.fill"
        case .try:
            return "lightbulb.fill"
        }
    }
    
    public var displayName: String {
        switch self {
        case .keep:
            return "Keep"
        case .problem:
            return "Problem"
        case .try:
            return "Try"
        }
    }
}
