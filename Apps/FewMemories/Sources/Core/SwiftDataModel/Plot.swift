//
//  Plot.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import Foundation
import SwiftData

@Model
public final class Plot {
    public var content: String?
    public var date: Date?
    public var point: Double?
    public var title: String?
    public var type: Int?
    
    public var folder: Folder?
    
    public init(
        content: String? = nil,
        date: Date? = Date(),
        point: Double = 0.0,
        title: String? = nil,
        type: Int = 0,
        folder: Folder? = nil
    ) {
        self.content = content
        self.date = date
        self.point = point
        self.title = title
        self.type = type
        self.folder = folder
    }
}
