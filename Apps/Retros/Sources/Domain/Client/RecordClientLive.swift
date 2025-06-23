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
    
    public func createOrUpdate(recordModel: RecordModel) -> RecordModel {
        do {
            let swiftDataRecord: Record
            
            if let existingRecord = recordModel.record {
                // 이미 저장된 record가 있으면 프로퍼티 업데이트
                existingRecord.type = recordModel.type.rawValue
                existingRecord.context = recordModel.context
                existingRecord.showAt = recordModel.showAt
                existingRecord.createAt = recordModel.createAt
                existingRecord.updateAt = recordModel.updateAt
                swiftDataRecord = existingRecord
            } else {
                // 새로운 record 생성
                swiftDataRecord = recordModel.toSwiftDataRecord()
                context.insert(swiftDataRecord)
            }
            
            try context.save()
            
            // 저장된 SwiftData 객체로부터 RecordModel을 생성하여 반환
            return RecordModel(from: swiftDataRecord)
        } catch {
            print("Failed to createOrUpdate record: \(error)")
            // 에러 발생 시 원본 RecordModel 반환
            return recordModel
        }
    }
    
    public func fetches() -> [RecordModel] {
        do {
            let descriptor: FetchDescriptor<Record> = .init()
            let result = try context.fetch(descriptor)
            return result.map { RecordModel(from: $0) }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    public func delete(recordModel: RecordModel) {
        do {
            if let existingRecord = recordModel.record {
                context.delete(existingRecord)
                print("Record deleted")
                try context.save()
            }
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
}

public class RecordClientTest: RecordClient {
    public func createOrUpdate(recordModel: RecordModel) -> RecordModel {
        fatalError()
    }
    
    public func fetches() -> [RecordModel] {
        fatalError()
    }
    
    public func delete(recordModel: RecordModel) {
        fatalError()
    }
}
