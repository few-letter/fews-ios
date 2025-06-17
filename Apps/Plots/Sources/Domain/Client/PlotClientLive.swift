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
    
    public init(context: ModelContext) {
        self.context = context
        // 초기화 시 마이그레이션 실행
        performMigrationIfNeeded()
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
        let migrationKey = "CoreDataToSwiftDataMigrationCompleted"
        
        // 이미 마이그레이션이 완료되었는지 확인
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }
        
        print("Starting Core Data to SwiftData migration...")
        
        do {
            try migrateCoreDataToSwiftData()
            UserDefaults.standard.set(true, forKey: migrationKey)
            print("Migration completed successfully")
        } catch {
            print("Migration failed: \(error)")
            // 마이그레이션 실패 시에도 앱은 계속 동작하도록 함
        }
    }
    
    private func migrateCoreDataToSwiftData() throws {
        let fileManager = FileManager.default
        
        // 기존 Core Data 스토어 위치 찾기
        let storeDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        let coreDataStoreURLs = [
            storeDirectory.appendingPathComponent("Cloud.sqlite"),
            storeDirectory.appendingPathComponent("Local.sqlite")
        ]
        
        for storeURL in coreDataStoreURLs {
            if fileManager.fileExists(atPath: storeURL.path) {
                print("Found Core Data store at: \(storeURL.path)")
                try migratePlotData(from: storeURL)
            }
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
            return
        }
        
        let managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        // Core Data에서 Plot 데이터 가져오기
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Plot")
        
        do {
            let coreDataPlots = try managedContext.fetch(fetchRequest)
            print("Found \(coreDataPlots.count) plots to migrate")
            
            // SwiftData로 변환 및 저장
            for coreDataPlot in coreDataPlots {
                try migrateIndividualPlot(coreDataPlot)
            }
            
        } catch {
            throw MigrationError.fetchFailed(error)
        }
    }
    
    private func migrateIndividualPlot(_ coreDataPlot: NSManagedObject) throws {
        // Core Data 속성 추출
        let title = coreDataPlot.value(forKey: "title") as? String ?? ""
        let content = coreDataPlot.value(forKey: "content") as? String ?? ""
        let type = coreDataPlot.value(forKey: "type") as? Int ?? 0
        let date = coreDataPlot.value(forKey: "date") as? Date ?? Date()
        
        // 중복 검사 (제목과 날짜로 확인)
        let existingPlots = try context.fetch(FetchDescriptor<Plot>(
            predicate: #Predicate<Plot> { plot in
                plot.title == title && plot.date == date
            }
        ))
        
        if existingPlots.isEmpty {
            // SwiftData Plot 생성
            let newPlot = Plot(folder: nil) // folder 관계는 별도 처리 필요
            newPlot.title = title
            newPlot.content = content
            newPlot.type = type
            newPlot.date = date
            
            context.insert(newPlot)
            print("Migrated plot: \(title)")
        } else {
            print("Plot already exists, skipping: \(title)")
        }
    }
    
    private func createCoreDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Plot Entity 생성
        let plotEntity = NSEntityDescription()
        plotEntity.name = "Plot"
        plotEntity.managedObjectClassName = "Plot"
        
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
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = true
        
        plotEntity.properties = [titleAttribute, contentAttribute, typeAttribute, dateAttribute]
        model.entities = [plotEntity]
        
        return model
    }
}

// MARK: - Migration Errors
enum MigrationError: Error, LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case storeNotFound
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch Core Data: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save SwiftData: \(error.localizedDescription)"
        case .storeNotFound:
            return "Core Data store not found"
        }
    }
}

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
