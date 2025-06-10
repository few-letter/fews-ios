//
//  Folder.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import Foundation
import SwiftData

@Model
public final class Folder: Equatable {
    public var id: UUID?
    public var name: String?
    public var createdDate: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Plot.folder)
    public var plots: [Plot]? = []
    
    public init(
        id: UUID = UUID(),
        name: String,
        createdDate: Date = Date(),
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
    }
}
