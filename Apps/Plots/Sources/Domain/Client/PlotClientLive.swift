//
//  PlotClientLive.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import Foundation
import SwiftData
import CoreData

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

// MARK: - Migration Logic
extension PlotClientLive {
    
    private func performMigrationIfNeeded() {
        let migrationKey = "CoreDataToSwiftDataMigrationCompleted_v2"
        let migrationInProgressKey = "CoreDataToSwiftDataMigrationInProgress"
        
        // 이미 마이그레이션이 완료되었는지 확인
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }
        
        // 마이그레이션이 진행 중인지 확인 (앱이 중간에 종료된 경우)
        if UserDefaults.standard.bool(forKey: migrationInProgressKey) {
            print("Previous migration was interrupted. Retrying...")
        }
        
        print("Starting Core Data to SwiftData migration...")
        UserDefaults.standard.set(true, forKey: migrationInProgressKey)
        
        do {
            try migrateCoreDataToSwiftData()
            
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
    
    private func migrateCoreDataToSwiftData() throws {
        let fileManager = FileManager.default
        
        // 기존 Core Data 스토어 위치 찾기
        guard let storeDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last else {
            throw MigrationError.storeNotFound
        }
        
        let coreDataStoreURLs = [
            storeDirectory.appendingPathComponent("Cloud.sqlite"),
            storeDirectory.appendingPathComponent("Local.sqlite")
        ]
        
        var migratedAnyStore = false
        
        for storeURL in coreDataStoreURLs {
            if fileManager.fileExists(atPath: storeURL.path) {
                print("Found Core Data store at: \(storeURL.path)")
                try migratePlotData(from: storeURL)
                migratedAnyStore = true
            }
        }
        
        if !migratedAnyStore {
            print("No Core Data stores found to migrate")
        }
    }
    
    private func migratePlotData(from storeURL: URL) throws {
        // Core Data 스택 설정
        let managedObjectModel = createCoreDataModel()
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: [
                    NSReadOnlyPersistentStoreOption: true,
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ]
            )
        } catch {
            print("Failed to add persistent store: \(error)")
            throw MigrationError.storeLoadFailed(error)
        }
        
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        // Core Data에서 Plot 데이터 가져오기
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Plot")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        var migratedCount = 0
        var errorCount = 0
        
        try managedContext.performAndWait {
            do {
                let coreDataPlots = try managedContext.fetch(fetchRequest)
                print("Found \(coreDataPlots.count) plots to migrate")
                
                // 배치 처리를 위한 임시 배열
                var plotsToMigrate: [(title: String, content: String, type: Int, date: Date)] = []
                
                for coreDataPlot in coreDataPlots {
                    // Core Data 속성 추출
                    let title = coreDataPlot.value(forKey: "title") as? String ?? ""
                    let content = coreDataPlot.value(forKey: "content") as? String ?? ""
                    let type = coreDataPlot.value(forKey: "type") as? Int ?? 0
                    let date = coreDataPlot.value(forKey: "date") as? Date ?? Date()
                    
                    plotsToMigrate.append((title, content, type, date))
                }
                
                // SwiftData 컨텍스트에서 배치 저장
                for plotData in plotsToMigrate {
                    do {
                        try autoreleasepool {
                            // 로컬 변수로 값 캡처
                            let titleToCheck = plotData.title
                            let dateToCheck = plotData.date
                            
                            // 중복 검사
                            let existingPlots = try self.context.fetch(FetchDescriptor<Plot>(
                                predicate: #Predicate<Plot> { plot in
                                    plot.title == titleToCheck && plot.date == dateToCheck
                                }
                            ))
                            
                            if existingPlots.isEmpty {
                                // SwiftData Plot 생성
                                let newPlot = Plot(folder: nil)
                                newPlot.title = plotData.title
                                newPlot.content = plotData.content
                                newPlot.type = plotData.type
                                newPlot.date = plotData.date
                                
                                self.context.insert(newPlot)
                                migratedCount += 1
                                
                                // 50개마다 저장하여 메모리 관리
                                if migratedCount % 50 == 0 {
                                    try self.context.save()
                                    print("Migrated \(migratedCount) plots...")
                                }
                            }
                        }
                    } catch {
                        errorCount += 1
                        print("Failed to migrate plot '\(plotData.title)': \(error)")
                    }
                }
                
                // 남은 데이터 저장
                if migratedCount % 50 != 0 {
                    try self.context.save()
                }
                
            } catch {
                throw MigrationError.fetchFailed(error)
            }
        }
        
        print("Migration complete. Migrated: \(migratedCount), Errors: \(errorCount)")
    }
    
    private func createCoreDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Plot Entity 생성
        let plotEntity = NSEntityDescription()
        plotEntity.name = "Plot"
        plotEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        
        // Plot 속성들 정의
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = true
        
        let contentAttribute = NSAttributeDescription()
        contentAttribute.name = "content"
        contentAttribute.attributeType = .stringAttributeType
        contentAttribute.isOptional = true
        
        let typeAttribute = NSAttributeDescription()
        typeAttribute.name = "type"
        typeAttribute.attributeType = .integer32AttributeType
        typeAttribute.defaultValue = 0
        typeAttribute.isOptional = false
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = true
        
        // ID 속성 추가 (Core Data에 있었을 수 있음)
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = true
        
        plotEntity.properties = [idAttribute, titleAttribute, contentAttribute, typeAttribute, dateAttribute]
        
        // Folder Entity (관계를 위해 필요할 수 있음)
        let folderEntity = NSEntityDescription()
        folderEntity.name = "Folder"
        folderEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        
        // Folder 관계 설정
        let folderRelationship = NSRelationshipDescription()
        folderRelationship.name = "folder"
        folderRelationship.destinationEntity = folderEntity
        folderRelationship.isOptional = true
        folderRelationship.deleteRule = .nullifyDeleteRule
        
        plotEntity.properties.append(folderRelationship)
        
        model.entities = [plotEntity, folderEntity]
        
        return model
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
