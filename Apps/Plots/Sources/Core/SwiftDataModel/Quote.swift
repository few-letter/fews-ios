//
//  Quote.swift
//  Plots
//
//  Created by AI Assistant on 2024.
//

import Foundation
import SwiftData

@Model
public final class Quote {
    public var id: String?
    public var page: Int?
    public var quote: String?
    
    @Relationship
    public var plot: Plot?
    
    public init(
        id: String? = UUID().uuidString,
        page: Int? = nil,
        quote: String? = nil,
        plot: Plot? = nil
    ) {
        self.id = id
        self.page = page
        self.quote = quote
        self.plot = plot
    }
}

public typealias QuoteID = String 