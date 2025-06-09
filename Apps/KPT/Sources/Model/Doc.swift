//
//  Doc.swift
//  KPT
//
//  Created by 송영모 on 3/18/24.
//

import Foundation
import SwiftData

public struct Doc: Identifiable {
    public var id: UUID
    public var originDate: Date
    public var selectedDate: Date
    public var records: [Record] = []
    
    public var keeps: [Record] {
        records
            .filter({ $0.type == RecordType.keep.rawValue })
            .sorted(by: { $0.showAt ?? .now > $1.showAt ?? .now })
    }
    public var problems: [Record] {
        records
            .filter({ $0.type == RecordType.problem.rawValue })
            .sorted(by: { $0.showAt ?? .now > $1.showAt ?? .now })
    }
    public var tries: [Record] {
        records
            .filter({ $0.type == RecordType.try.rawValue })
            .sorted(by: { $0.showAt ?? .now > $1.showAt ?? .now })
    }
    
    public var date: Date
    
    public init(
        id: UUID = .init(),
        records: [Record] = [],
        originDate: Date,
        date: Date
    ) {
        self.id = id
        self.records = records
        self.originDate = originDate
        self.selectedDate = originDate
        self.date = date
    }
}
