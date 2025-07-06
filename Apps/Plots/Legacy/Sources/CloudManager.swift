//
//  CloudManager.swift
//  LegacyPlots
//
//  Created by 송영모 on 7/6/25.
//

import Foundation
import CloudKit
import CoreData

// MARK: - PlotCloudManager for Advanced Operations
public class PlotCloudManager {
    public static let shared = PlotCloudManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        // 여러 방법으로 Core Data 모델을 찾기
        var modelURL: URL?
        var model: NSManagedObjectModel?
        
        // 1. LegacyPlots 프레임워크 번들에서 찾기
        let frameworkBundle = Bundle(for: PlotCloudManager.self)
        modelURL = frameworkBundle.url(forResource: "plotfolio", withExtension: "momd")
        
        // 2. 메인 번들에서 .momd 확장자로 찾기
        if modelURL == nil {
            modelURL = Bundle.main.url(forResource: "plotfolio", withExtension: "momd")
        }
        
        // 3. 모든 번들에서 찾기
        if modelURL == nil {
            for bundle in Bundle.allBundles {
                if let url = bundle.url(forResource: "plotfolio", withExtension: "momd") {
                    modelURL = url
                    break
                }
            }
        }
        
        if let url = modelURL {
            model = NSManagedObjectModel(contentsOf: url)
            print("✅ Found Core Data model at: \(url.lastPathComponent)")
        }
        
        // 4. 기본 방법으로 시도
        if model == nil {
            print("🔍 Trying default NSManagedObjectModel.mergedModel approach...")
            model = NSManagedObjectModel.mergedModel(from: [frameworkBundle, Bundle.main])
        }
        
        guard let finalModel = model else {
            fatalError("Failed to load Core Data model from any bundle")
        }
        
        let container = NSPersistentCloudKitContainer(name: "plotfolio", managedObjectModel: finalModel)
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        // 모델 정보 출력 (개발 시에만)
        print("📊 Core Data Model loaded - Entities: \(finalModel.entities.map { $0.name ?? "Unknown" })")
        
        let hasCloudConfig = finalModel.configurations.contains("Cloud")
        let hasLocalConfig = finalModel.configurations.contains("Local")
        
        if hasCloudConfig && hasLocalConfig {
            // 기존 방식 (Cloud/Local 구성이 있는 경우)
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
        } else {
            // 기본 구성 사용 (구성이 없거나 다른 경우)
            print("☁️ Using default configuration with CloudKit")
            let storeUrl = storeDirectory.appendingPathComponent("plotfolio.sqlite")
            let storeDescription = NSPersistentStoreDescription(url: storeUrl)
            
            // CloudKit 설정 (가능한 경우)
            storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.plotfolio"
            )
            
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        return container
    }()
}

// MARK: - PlotCloudManager Extensions
extension PlotCloudManager {
    public func newPlot() -> NSManagedObject {
        let viewContext = self.persistentContainer.viewContext
        viewContext.reset()
        
        let newPlot = NSEntityDescription.insertNewObject(forEntityName: "Plot", into: viewContext)
        
        newPlot.setValue("", forKey: "title")
        newPlot.setValue("", forKey: "content")
        newPlot.setValue(0, forKey: "type")
        newPlot.setValue(Date(), forKey: "date")
        
        return newPlot
    }
    
    public func fetch() -> [NSManagedObject] {
        let viewContext = self.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Plot")
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print(error)
            return []
        }
    }
    
    public func fetch(id: NSManagedObjectID) -> NSManagedObject? {
        let viewContext = self.persistentContainer.viewContext
        
        do {
            return try viewContext.existingObject(with: id)
        } catch {
            print(error)
            return nil
        }
    }
    
    public func save() {
        let viewContext = self.persistentContainer.viewContext

        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    public func delete(id: NSManagedObjectID) {
        let viewContext = self.persistentContainer.viewContext
        
        if let plot = self.fetch(id: id) {
            viewContext.delete(plot)
            self.save()
        }
    }
}

// MARK: - Migration Error
public enum MigrationError: Error {
    case storeNotFound
    case migrationFailed
} 
