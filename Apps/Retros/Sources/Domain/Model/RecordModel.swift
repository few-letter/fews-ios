//
//  RecordModel.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftData

public struct RecordModel: Identifiable {
    public var id: UUID
    public var type: RecordType
    public var context: String
    public var showAt: Date
    public var createAt: Date
    public var updateAt: Date
    
    // SwiftData 객체 참조 (저장용)
    public var record: Record?
    
    public init(
        id: UUID,
        type: RecordType,
        context: String,
        showAt: Date,
        createAt: Date = .now,
        updateAt: Date,
        record: Record? = nil
    ) {
        self.id = id
        self.type = type
        self.context = context
        self.showAt = showAt
        self.createAt = createAt
        self.updateAt = updateAt
        self.record = record
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension RecordModel {
    /// SwiftData Record 객체로부터 RecordModel 생성
    public init(from swiftDataRecord: Record) {
        self.id = swiftDataRecord.id ?? .init()
        self.type = .init(rawValue: swiftDataRecord.type ?? 0) ?? .keep
        self.context = swiftDataRecord.context ?? ""
        self.showAt = swiftDataRecord.showAt ?? .now
        self.createAt = swiftDataRecord.createAt ?? .now
        self.updateAt = swiftDataRecord.updateAt ?? .now
        self.record = swiftDataRecord
    }
    
    /// RecordModel을 SwiftData Record 객체로 변환
    public func toSwiftDataRecord() -> Record {
        return Record(
            id: self.id,
            type: self.type,
            context: self.context,
            showAt: self.showAt,
            createAt: self.createAt,
            updateAt: self.updateAt
        )
    }
}
