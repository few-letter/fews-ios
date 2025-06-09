//
//  Record.swift
//  KPT
//
//  Created by 송영모 on 3/18/24.
//

import Foundation
import SwiftData

@Model
public final class Record {
    public var id: UUID?
    public var type: Int?
    public var context: String?
    public var showAt: Date?
    public var createAt: Date?
    public var updateAt: Date?
    public var isDeleted: Bool?
    
    public init(
        id: UUID? = .init(),
        type: RecordType,
        context: String,
        showAt: Date,
        createAt: Date = .now,
        updateAt: Date
    ) {
        self.id = id
        self.type = type.rawValue
        self.context = context
        self.showAt = showAt
        self.createAt = createAt
        self.updateAt = updateAt
    }
}
