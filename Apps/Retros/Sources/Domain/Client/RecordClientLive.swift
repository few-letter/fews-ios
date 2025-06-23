//
//  RecordClient.swift
//  Toff
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftData

public class RecordClientLive: RecordClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
    }
    
    public func create(recordModel: RecordModel) -> RecordModel {
        let record = recordModel.toSwiftDataRecord()
        save(record: record)
        return RecordModel(from: record)
    }
    
    public func fetches() -> [RecordModel] {
        do {
            let descriptor: FetchDescriptor<Record> = .init()
            let result = try context.fetch(descriptor)
            return result.map { RecordModel(from: $0) }
        } catch {
            return []
        }
    }
    
    public func update(recordModel: RecordModel) {
        do {
            if let existingRecord = recordModel.record {
                // 기존 Record 객체 업데이트
                existingRecord.type = recordModel.type.rawValue
                existingRecord.context = recordModel.context
                existingRecord.showAt = recordModel.showAt
                existingRecord.createAt = recordModel.createAt
                existingRecord.updateAt = recordModel.updateAt
            }
            try context.save()
        } catch {
            print("Failed to update record: \(error)")
        }
    }
    
    public func delete(recordModel: RecordModel) {
        do {
            if let existingRecord = recordModel.record {
                context.delete(existingRecord)
                print("delete")
                try context.save()
            }
        } catch {
            
        }
    }
    
    private func save(record: Record) {
        do {
            context.insert(record)
            try context.save()
        } catch {
        }
    }
}

public class RecordClientTest: RecordClient {
    public func create(recordModel: RecordModel) -> RecordModel {
        fatalError()
    }
    
    public func fetches() -> [RecordModel] {
        fatalError()
    }
    
    public func update(recordModel: RecordModel) {
        fatalError()
    }
    
    public func delete(recordModel: RecordModel) {
        fatalError()
    }
}
