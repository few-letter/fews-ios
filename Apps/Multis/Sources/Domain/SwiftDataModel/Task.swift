//
//  Task.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftData
import Foundation

@Model
public final class Task {
    public var id: UUID?
    public var title: String?
    public var time: Int?
    public var date: Date?
    
    public init(
        id: UUID? = .init(),
        title: String? = nil,
        date: Date? = nil,
        time: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.date = date
    }
}
