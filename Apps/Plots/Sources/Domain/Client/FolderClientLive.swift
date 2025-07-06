//
//  FolderClientLive.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import Foundation
import SwiftData

public class FolderClientLive: FolderClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
        
        createMockDataIfNeeded()
    }
    
    private func createMockDataIfNeeded() {
        // Mock 데이터 생성 로직
        do {
            let descriptor = FetchDescriptor<Folder>()
            let existingFolders = try context.fetch(descriptor)
            
            if existingFolders.isEmpty {
                // Mock 데이터 생성
                let rootFolder = Folder(
                    id: UUID().uuidString,
                    name: "루트 폴더",
                    createdDate: Date()
                )
                
                let subFolder = Folder(
                    id: UUID().uuidString,
                    name: "서브 폴더",
                    createdDate: Date()
                )
                
                subFolder.parentFolder = rootFolder
                rootFolder.folders?.append(subFolder)
                
                context.insert(rootFolder)
                context.insert(subFolder)
                try context.save()
            }
        } catch {
            print("Failed to create mock data: \(error)")
        }
    }
    
    public func createOrUpdate(folder: FolderModel) -> FolderModel {
        do {
            let swiftDataFolder: Folder
            if let existingFolder = folder.folder {
                folder.updateSwiftData()
                swiftDataFolder = existingFolder
            } else {
                swiftDataFolder = folder.toSwiftDataFolder()
                swiftDataFolder.parentFolder = folder.parentFolder
                context.insert(swiftDataFolder)
            }
            try context.save()
            
            return FolderModel(from: swiftDataFolder)
        } catch {
            print("Failed to createOrUpdate folder: \(error)")
            return folder
        }
    }
    
    public func fetches(parentFolder: FolderModel?) -> [FolderModel] {
        do {
            let descriptor: FetchDescriptor<Folder>
            if let parentFolderID = parentFolder?.folder?.id {
                descriptor = FetchDescriptor<Folder>(
                    predicate: #Predicate { folder in
                        folder.parentFolder?.id == parentFolderID
                    },
                    sortBy: [.init(\.createdDate)]
                )
            } else {
                descriptor = FetchDescriptor<Folder>(
                    predicate: #Predicate { folder in
                        folder.parentFolder == nil
                    },
                    sortBy: [.init(\.createdDate)]
                )
            }
            
            let result = try context.fetch(descriptor)
            return result.map { FolderModel(from: $0) }
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }
    
    public func delete(folder: FolderModel) {
        do {
            if let existingFolder = folder.folder {
                context.delete(existingFolder)
                try context.save()
            }
        } catch {
            print("Failed to delete folder: \(error)")
        }
    }
}
