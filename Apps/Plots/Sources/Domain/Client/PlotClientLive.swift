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
                    content: "샘플 내용",
                    date: Date(),
                    point: 8.5,
                    title: "첫 번째 플롯",
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
class PlotCloudManager {
    static let shared = PlotCloudManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "plotfolio")
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        let localUrl = storeDirectory.appendingPathComponent("Local.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localUrl)
        localStoreDescription.configuration = "Local"
        
        let cloudUrl = storeDirectory.appendingPathComponent("Cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudUrl)
        cloudStoreDescription.configuration = "Cloud"
        
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.plotfolio"
        )
        
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Could not load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    func fetchAllPlots() -> [NSManagedObject] {
        let viewContext = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Plot")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch plots from Core Data: \(error)")
            return []
        }
    }
}

// MARK: - Migration Logic
extension PlotClientLive {
    
    private func performMigrationIfNeeded() {
        let migrationKey = "CoreDataToSwiftDataMigrationCompleted_v3"
        let migrationInProgressKey = "CoreDataToSwiftDataMigrationInProgress_v3"
        
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
            storeDirectory.appendingPathComponent("Local.sqlite")
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
        let cloudManager = PlotCloudManager.shared
        let coreDataPlots = cloudManager.fetchAllPlots()
        
        if coreDataPlots.isEmpty {
            print("No plots found in Core Data")
            return
        }
        
        // CoreData 데이터를 SwiftData로 마이그레이션
        for coreDataPlot in coreDataPlots {
            let title = coreDataPlot.value(forKey: "title") as? String ?? ""
            let content = coreDataPlot.value(forKey: "content") as? String ?? ""
            let date = coreDataPlot.value(forKey: "date") as? Date ?? Date()
            let point = coreDataPlot.value(forKey: "point") as? Double ?? 0.0
            let type = coreDataPlot.value(forKey: "type") as? Int ?? 0
            
            let newPlot = Plot(
                content: content,
                date: date,
                point: point,
                title: title,
                type: type,
                folder: nil
            )
            
            context.insert(newPlot)
        }
        
        try context.save()
        print("Successfully migrated \(coreDataPlots.count) plots to SwiftData")
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
                storeDirectory.appendingPathComponent("Local.sqlite")
            ]
            
            for storeURL in coreDataStoreURLs {
                if fileManager.fileExists(atPath: storeURL.path) {
                    let backupURL = backupDirectory.appendingPathComponent(storeURL.lastPathComponent)
                    try fileManager.copyItem(at: storeURL, to: backupURL)
                    print("Backed up Core Data store to: \(backupURL.path)")
                }
            }
        } catch {
            print("Failed to backup Core Data stores: \(error)")
        }
    }
}

enum MigrationError: Error {
    case storeNotFound
    case migrationFailed
}


