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
    public var id: String?
    public var name: String?
    public var createdDate: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Plot.folder)
    public var plots: [Plot]? = []
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        createdDate: Date = Date(),
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
    }
}

public typealias FolderID = String
