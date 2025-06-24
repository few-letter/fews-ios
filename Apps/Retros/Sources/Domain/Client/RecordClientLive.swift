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
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        let existingRecords = fetches()
        guard existingRecords.isEmpty else {
            return
        }
        
        let mockRecords = generateMockRecords()
        
        for mockRecord in mockRecords {
            let swiftDataRecord = mockRecord.toSwiftDataRecord()
            context.insert(swiftDataRecord)
        }
        
        do {
            try context.save()
            print("Mock data created successfully: \(mockRecords.count) records")
        } catch {
            print("Failed to create mock data: \(error)")
        }
    }
    
    private func generateMockRecords() -> [RecordModel] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        let keepRecords = [
            "Daily standup meetings helped us stay aligned as a team",
            "Code review process caught several potential bugs early",
            "Using automated testing saved us debugging time",
            "Clear documentation made onboarding new team members smooth",
            "Pair programming sessions improved code quality",
            "Sprint retrospectives led to actionable improvements",
            "Using feature flags for safer deployments",
            "Team knowledge sharing sessions were valuable",
            "Automated CI/CD pipeline reduced manual errors",
            "Regular one-on-ones improved team communication"
        ]
        
        let problemRecords = [
            "Database queries were slower than expected during peak hours",
            "Deployment process took longer due to manual steps",
            "Communication gaps between frontend and backend teams",
            "Testing environment was unstable, causing delays",
            "Code merge conflicts increased with larger team",
            "Meeting overload reduced actual development time",
            "Lack of proper error monitoring in production",
            "Technical debt started affecting feature development speed",
            "Inconsistent code style across the codebase",
            "Limited test coverage for critical components"
        ]
        
        let tryRecords = [
            "Implement database indexing to improve query performance",
            "Set up automated deployment pipeline for faster releases",
            "Weekly cross-team sync meetings to improve communication",
            "Migrate to more stable testing infrastructure",
            "Establish git workflow with feature branches",
            "Implement time-blocking for focused development work",
            "Add comprehensive error tracking and alerting",
            "Dedicate sprint capacity for technical debt reduction",
            "Introduce automated code formatting tools",
            "Increase test coverage to 80% for core modules"
        ]
        
        var mockRecords: [RecordModel] = []
        
        let targetDates = [
            now, // 오늘 날짜
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 3))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 8))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 15))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 18))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 22))!,
            calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 25))!
        ].map { calendar.startOfDay(for: $0) }
        
        let dateDistribution = [
            (targetDates[0], 6), // 오늘에 6개
            (targetDates[1], 8), // 3일에 8개 (완전한 KPT 세트)
            (targetDates[2], 5), // 8일에 5개
            (targetDates[3], 4), // 15일에 4개
            (targetDates[4], 4), // 18일에 4개
            (targetDates[5], 2), // 22일에 2개
            (targetDates[6], 1)  // 25일에 1개
        ]
        
        var keepIndex = 0
        var problemIndex = 0
        var tryIndex = 0
        
        for (date, count) in dateDistribution {
            let typesForThisDate = generateTypesForDate(count: count)
            
            for (hour, type) in typesForThisDate.enumerated() {
                let recordDate = calendar.date(byAdding: .hour, value: 9 + hour, to: date)!
                let context: String
                
                switch type {
                case .keep:
                    context = keepRecords[keepIndex % keepRecords.count]
                    keepIndex += 1
                case .problem:
                    context = problemRecords[problemIndex % problemRecords.count]
                    problemIndex += 1
                case .try:
                    context = tryRecords[tryIndex % tryRecords.count]
                    tryIndex += 1
                }
                
                let record = RecordModel(
                    id: UUID(),
                    type: type,
                    context: context,
                    showAt: recordDate,
                    createAt: recordDate,
                    updateAt: recordDate
                )
                
                mockRecords.append(record)
            }
        }
        
        return mockRecords
    }
    
    private func generateTypesForDate(count: Int) -> [RecordType] {
        let allTypes: [RecordType] = [.keep, .problem, .try]
        var types: [RecordType] = []
        
        for i in 0..<count {
            let type = allTypes[i % allTypes.count]
            types.append(type)
        }
        
        return types.shuffled()
    }
    
    public func createOrUpdate(recordModel: RecordModel) -> RecordModel {
        do {
            let swiftDataRecord: Record
            
            if let existingRecord = recordModel.record {
                existingRecord.type = recordModel.type.rawValue
                existingRecord.context = recordModel.context
                existingRecord.showAt = recordModel.showAt
                existingRecord.createAt = recordModel.createAt
                existingRecord.updateAt = recordModel.updateAt
                swiftDataRecord = existingRecord
            } else {
                swiftDataRecord = recordModel.toSwiftDataRecord()
                context.insert(swiftDataRecord)
            }
            
            try context.save()
            
            return RecordModel(from: swiftDataRecord)
        } catch {
            print("Failed to createOrUpdate record: \(error)")
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
