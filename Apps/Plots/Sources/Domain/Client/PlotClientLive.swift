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
        // 백그라운드에서 마이그레이션 실행
        migrationQueue.async { [weak self] in
            self?.performMigrationIfNeeded()
        }
    }
    
    public func create(folder: Folder?) -> Plot {
        let plot = Plot(folder: folder)
        save(plot: plot)
        return plot
    }
    
    public func fetches(folder: Folder?) -> [Plot] {
        do {
            var descriptor: FetchDescriptor<Plot>
            if let folderID = folder?.id {
                descriptor = FetchDescriptor<Plot>(
                    predicate: #Predicate { plot in
                        plot.folder?.id == folderID
                    },
                    sortBy: [.init(\.date)]
                )
            } else {
                descriptor = FetchDescriptor<Plot>(
                    sortBy: [.init(\.date)]
                )
            }
            let result = try context.fetch(descriptor)
            return result
        } catch {
            print("Failed to fetch plots: \(error)")
            return []
        }
    }
    
    public func update(plot: Plot) -> Void {
        do {
            try context.save()
        } catch {
            print("Plot update failed: \(error)")
        }
    }
    
    public func delete(plot: Plot) -> Void {
        do {
            context.delete(plot)
            try context.save()
        } catch {
            print("Plot delete failed: \(error)")
        }
    }
    
    private func save(plot: Plot) {
        do {
            context.insert(plot)
            try context.save()
        } catch {
            print("Plot save failed: \(error)")
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
        
        print("Found \(coreDataPlots.count) plots to migrate")
        
        var migratedCount = 0
        var errorCount = 0
        
        // 각 Plot을 SwiftData로 마이그레이션
        for coreDataPlot in coreDataPlots {
            do {
                try autoreleasepool {
                    // Core Data 속성 추출
                    let title = coreDataPlot.value(forKey: "title") as? String ?? ""
                    let content = coreDataPlot.value(forKey: "content") as? String ?? ""
                    let type = coreDataPlot.value(forKey: "type") as? Int ?? 0
                    let date = coreDataPlot.value(forKey: "date") as? Date ?? Date()
                    
                    // 중복 검사 - 로컬 변수로 값 캡처
                    let titleToCheck = title
                    let dateToCheck = date
                    
                    let existingPlots = try self.context.fetch(FetchDescriptor<Plot>(
                        predicate: #Predicate<Plot> { plot in
                            plot.title == titleToCheck && plot.date == dateToCheck
                        }
                    ))
                    
                    if existingPlots.isEmpty {
                        // SwiftData Plot 생성
                        let newPlot = Plot(folder: nil)
                        newPlot.title = title
                        newPlot.content = content
                        newPlot.type = type
                        newPlot.date = date
                        
                        self.context.insert(newPlot)
                        migratedCount += 1
                        
                        // 50개마다 저장하여 메모리 관리
                        if migratedCount % 50 == 0 {
                            try self.context.save()
                            print("Migrated \(migratedCount) plots...")
                        }
                    } else {
                        print("Plot already exists: \(title)")
                    }
                }
            } catch {
                errorCount += 1
                let title = coreDataPlot.value(forKey: "title") as? String ?? "Unknown"
                print("Failed to migrate plot '\(title)': \(error)")
            }
        }
        
        // 남은 데이터 저장
        if migratedCount % 50 != 0 {
            try self.context.save()
        }
        
        print("Migration complete. Migrated: \(migratedCount), Errors: \(errorCount)")
    }
    
    private func backupCoreDataStores() {
        let fileManager = FileManager.default
        guard let storeDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last else {
            return
        }
        
        let backupDirectory = storeDirectory.appendingPathComponent("CoreDataBackup")
        
        do {
            try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
            
            let coreDataFiles = [
                "Cloud.sqlite", "Cloud.sqlite-shm", "Cloud.sqlite-wal",
                "Local.sqlite", "Local.sqlite-shm", "Local.sqlite-wal"
            ]
            
            for fileName in coreDataFiles {
                let sourceURL = storeDirectory.appendingPathComponent(fileName)
                if fileManager.fileExists(atPath: sourceURL.path) {
                    let destinationURL = backupDirectory.appendingPathComponent(fileName)
                    try fileManager.moveItem(at: sourceURL, to: destinationURL)
                    print("Backed up: \(fileName)")
                }
            }
        } catch {
            print("Failed to backup Core Data stores: \(error)")
        }
    }
}

// MARK: - Migration Errors
enum MigrationError: Error, LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case storeNotFound
    case storeLoadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch Core Data: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save SwiftData: \(error.localizedDescription)"
        case .storeNotFound:
            return "Core Data store not found"
        case .storeLoadFailed(let error):
            return "Failed to load Core Data store: \(error.localizedDescription)"
        }
    }
}

// MARK: - Test Implementation
public class PlotClientTest: PlotClient {
    public func create(folder: Folder?) -> Plot {
        fatalError()
    }
    
    public func fetches(folder: Folder?) -> [Plot] {
        fatalError()
    }
    
    public func update(plot: Plot) {
        fatalError()
    }
    
    public func delete(plot: Plot) {
        fatalError()
    }
}
