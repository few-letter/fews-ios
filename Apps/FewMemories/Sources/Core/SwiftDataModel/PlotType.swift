//
//  PlotType.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation

enum PlotType: Int, CaseIterable {
    case movie
    case book
    case exhibition
    case concert
    case music
    case food
    case place
    case media
    case etc
    
    var title: String {
        switch self {
        case .movie: return "movie"
        case .book: return "book"
        case .exhibition: return "exhibition"
        case .concert: return "concert"
        case .music: return "music"
        case .food: return "food"
        case .place: return "place"
        case .media: return "media"
        case .etc: return "etc"
        }
    }
}
