//
//  PlotClientLive.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import Foundation
import SwiftData
import CoreData
import CloudKit
import LegacyPlots

public class PlotClientLive: PlotClient {
    private var context: ModelContext
    private let migrationQueue = DispatchQueue(label: "com.fewmemories.migration", qos: .background)
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
        
        // 백그라운드에서 마이그레이션 실행
        migrationQueue.async { [weak self] in
            self?.performMigrationIfNeeded()
        }
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        // Mock 데이터 생성 로직
        do {
            let descriptor = FetchDescriptor<Plot>()
            let existingPlots = try context.fetch(descriptor)
            
            if existingPlots.isEmpty {
                // Mock 데이터 생성
                let mockPlot = Plot(
                    content: "sample",
                    date: Date(),
                    point: 3.5,
                    title: "first plots",
                    type: 0,
                    folder: nil
                )
                
                context.insert(mockPlot)
                try context.save()
            }
        } catch {
            print("Failed to create mock data: \(error)")
        }
    }
    
    public func createOrUpdate(plot: PlotModel) -> PlotModel {
        do {
            let swiftDataPlot: Plot
            
            if let existingPlot = plot.plot {
                // 기존 객체 업데이트 - updateSwiftData() 메서드 사용
                plot.updateSwiftData()
                swiftDataPlot = existingPlot
            } else {
                // 새 객체 생성
                swiftDataPlot = plot.toSwiftDataPlot()
                context.insert(swiftDataPlot)
            }
            
            try context.save()
            
            return PlotModel(from: swiftDataPlot)
        } catch {
            print("Failed to createOrUpdate plot: \(error)")
            return plot
        }
    }
    
    public func fetches() -> [PlotModel] {
        do {
            let descriptor = FetchDescriptor<Plot>(
                sortBy: [.init(\.date)]
            )
            let result = try context.fetch(descriptor)
            return result.map { PlotModel(from: $0) }
        } catch {
            print("Failed to fetch plots: \(error)")
            return []
        }
    }
    
    public func fetches(folder: FolderModel?) -> [PlotModel] {
        do {
            var descriptor: FetchDescriptor<Plot>
            if let folderID = folder?.folder?.id {
                descriptor = FetchDescriptor<Plot>(
                    predicate: #Predicate { plot in
                        plot.folder?.id == folderID
                    },
                    sortBy: [.init(\.date)]
                )
            } else {
                descriptor = FetchDescriptor<Plot>(
                    predicate: #Predicate { plot in
                        plot.folder == nil
                    },
                    sortBy: [.init(\.date)]
                )
            }
            let result = try context.fetch(descriptor)
            return result.map { PlotModel(from: $0) }
        } catch {
            print("Failed to fetch plots: \(error)")
            return []
        }
    }
    
    public func delete(plot: PlotModel) {
        do {
            if let existingPlot = plot.plot {
                context.delete(existingPlot)
                try context.save()
            }
        } catch {
            print("Failed to delete plot: \(error)")
        }
    }
}

// MARK: - PlotCloudManager for Migration
// PlotCloudManager는 이제 LegacyPlots 모듈에서 import됩니다.

// MARK: - Migration Logic
extension PlotClientLive {
    
    private func performMigrationIfNeeded() {
        let migrationKey = "CoreDataToSwiftDataMigrationCompleted_v5"
        let migrationInProgressKey = "CoreDataToSwiftDataMigrationInProgress_v5"
        
        // 이미 마이그레이션이 완료되었는지 확인
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }
        
        // 마이그레이션이 진행 중인지 확인 (앱이 중간에 종료된 경우)
        if UserDefaults.standard.bool(forKey: migrationInProgressKey) {
            print("Previous migration was interrupted. Retrying...")
        }
        
        print("Starting Core Data to SwiftData migration using PlotCloudManager...")
        UserDefaults.standard.set(true, forKey: migrationInProgressKey)
        
        do {
            try migrateCoreDataToSwiftDataWithCloudManager()
            
            // 마이그레이션 성공
            UserDefaults.standard.set(true, forKey: migrationKey)
            UserDefaults.standard.set(false, forKey: migrationInProgressKey)
            print("Migration completed successfully")
            
            // 성공 후 기존 Core Data 파일 백업
            backupCoreDataStores()
            
        } catch {
            print("Migration failed: \(error)")
            UserDefaults.standard.set(false, forKey: migrationInProgressKey)
            // 마이그레이션 실패 시에도 앱은 계속 동작하도록 함
        }
    }
    
    private func migrateCoreDataToSwiftDataWithCloudManager() throws {
        let fileManager = FileManager.default
        
        // 기존 Core Data 스토어 위치 확인
        guard let storeDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last else {
            throw MigrationError.storeNotFound
        }
        
        let coreDataStoreURLs = [
            storeDirectory.appendingPathComponent("Cloud.sqlite"),
            storeDirectory.appendingPathComponent("Local.sqlite"),
            storeDirectory.appendingPathComponent("plotfolio.sqlite") // 기본 구성 스토어도 확인
        ]
        
        var hasAnyStore = false
        for storeURL in coreDataStoreURLs {
            if fileManager.fileExists(atPath: storeURL.path) {
                hasAnyStore = true
                print("Found Core Data store at: \(storeURL.path)")
            }
        }
        
        if !hasAnyStore {
            print("No Core Data stores found to migrate")
            return
        }
        
        // PlotCloudManager를 사용하여 기존 데이터 가져오기
        print("Initializing CloudManager for migration...")
        let cloudManager = PlotCloudManager.shared
        
        do {
            let coreDataPlots = cloudManager.fetch()
            
            if coreDataPlots.isEmpty {
                print("No plots found in Core Data - migration completed (empty)")
                return
            }
            
            print("Found \(coreDataPlots.count) plots in Core Data to migrate")
            
            // SwiftData에서 기존 데이터 확인
            let existingPlotsDescriptor = FetchDescriptor<Plot>()
            let existingPlots = try context.fetch(existingPlotsDescriptor)
            print("Found \(existingPlots.count) existing plots in SwiftData")
            
            // 기존 데이터와 비교하여 중복 확인을 위한 Set 생성
            var existingPlotKeys = Set<String>()
            for existingPlot in existingPlots {
                let key = createPlotKey(title: existingPlot.title ?? "", 
                                      content: existingPlot.content ?? "", 
                                      date: existingPlot.date ?? Date(), 
                                      point: existingPlot.point ?? 0.0,
                                      type: existingPlot.type ?? 0)
                existingPlotKeys.insert(key)
            }
            
            // CoreData 데이터를 SwiftData로 마이그레이션 (중복 제외)
            var migratedCount = 0
            var skippedCount = 0
            
            for coreDataPlot in coreDataPlots {
                let title = coreDataPlot.value(forKey: "title") as? String ?? ""
                let content = coreDataPlot.value(forKey: "content") as? String ?? ""
                let date = coreDataPlot.value(forKey: "date") as? Date ?? Date()
                let point = coreDataPlot.value(forKey: "point") as? Double ?? 0.0
                let type = coreDataPlot.value(forKey: "type") as? Int ?? 0
                
                // 중복 체크
                let plotKey = createPlotKey(title: title, content: content, date: date, point: point, type: type)
                
                if existingPlotKeys.contains(plotKey) {
                    skippedCount += 1
                    continue // 이미 존재하는 데이터는 건너뛰기
                }
                
                let newPlot = Plot(
                    content: content,
                    date: date,
                    point: point,
                    title: title,
                    type: type,
                    folder: nil
                )
                
                context.insert(newPlot)
                existingPlotKeys.insert(plotKey) // 새로 추가된 키도 Set에 추가
                migratedCount += 1
                
                if migratedCount % 10 == 0 {
                    print("Migrated \(migratedCount)/\(coreDataPlots.count - skippedCount) new plots...")
                }
            }
            
            print("Migration summary:")
            print("- Total Core Data plots: \(coreDataPlots.count)")
            print("- Existing SwiftData plots: \(existingPlots.count)")
            print("- Skipped (duplicates): \(skippedCount)")
            print("- Newly migrated: \(migratedCount)")
            
            if migratedCount > 0 {
                print("Saving migrated data to SwiftData...")
                try context.save()
                print("✅ Successfully migrated \(migratedCount) new plots to SwiftData")
            } else {
                print("✅ No new plots to migrate - all data already exists")
            }
            
        } catch {
            print("Error during migration: \(error)")
            throw error
        }
    }
    
    // 플롯 데이터의 고유 키를 생성하는 메서드
    private func createPlotKey(title: String, content: String, date: Date, point: Double, type: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        
        // 제목, 내용, 날짜, 점수, 타입을 조합하여 고유 키 생성
        let key = "\(title)|\(content)|\(dateString)|\(point)|\(type)"
        
        // 긴 키를 짧게 만들기 위해 해시 사용
        return String(key.hashValue)
    }
    
    private func backupCoreDataStores() {
        let fileManager = FileManager.default
        
        guard let storeDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last else {
            return
        }
        
        let backupDirectory = storeDirectory.appendingPathComponent("CoreDataBackup")
        
        do {
            if !fileManager.fileExists(atPath: backupDirectory.path) {
                try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
            }
            
            let coreDataStoreURLs = [
                storeDirectory.appendingPathComponent("Cloud.sqlite"),
                storeDirectory.appendingPathComponent("Local.sqlite"),
                storeDirectory.appendingPathComponent("plotfolio.sqlite")
            ]
            
            var backedUpCount = 0
            for storeURL in coreDataStoreURLs {
                if fileManager.fileExists(atPath: storeURL.path) {
                    let backupURL = backupDirectory.appendingPathComponent(storeURL.lastPathComponent)
                    
                    // 기존 백업 파일이 있으면 삭제
                    if fileManager.fileExists(atPath: backupURL.path) {
                        try fileManager.removeItem(at: backupURL)
                    }
                    
                    try fileManager.copyItem(at: storeURL, to: backupURL)
                    print("Backed up Core Data store: \(storeURL.lastPathComponent)")
                    backedUpCount += 1
                }
            }
            
            if backedUpCount > 0 {
                print("Successfully backed up \(backedUpCount) Core Data store file(s)")
            } else {
                print("No Core Data store files found to backup")
            }
        } catch {
            print("Failed to backup Core Data stores: \(error)")
        }
    }
}

// MigrationError는 이제 LegacyPlots 모듈에서 import됩니다.


