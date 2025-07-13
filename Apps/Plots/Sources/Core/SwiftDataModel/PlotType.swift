//
//  PlotType.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation

public enum PlotType: Int, CaseIterable {
    case novel
    case essay
    case selfDevelopment
    case business
    case psychology
    case philosophy
    case history
    case science
    case biography
    case poetry
    case comics
    case etc
    
    var title: String {
        switch self {
        case .novel: return "Novel"
        case .essay: return "Essay"
        case .selfDevelopment: return "Self-Development"
        case .business: return "Business"
        case .psychology: return "Psychology"
        case .philosophy: return "Philosophy"
        case .history: return "History"
        case .science: return "Science"
        case .biography: return "Biography"
        case .poetry: return "Poetry"
        case .comics: return "Comics"
        case .etc: return "Others"
        }
    }
}
