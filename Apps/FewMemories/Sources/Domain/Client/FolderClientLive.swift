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
    }
    
    public func create(parentFolder: Folder?, name: String) -> Folder {
        let folder = Folder(name: name)
        folder.parentFolder = parentFolder
        if let parentFolder = parentFolder {
            parentFolder.folders?.append(folder)
        }
        self.save(folder)
        return folder
    }
    
    public func fetches(parentFolder: Folder?) -> [Folder] {
        do {
            if let parentFolderID = parentFolder?.id {
                let descriptor: FetchDescriptor<Folder> = .init(
                    predicate: #Predicate { folder in
                        folder.parentFolder?.id == parentFolderID
                    },
                    sortBy: [.init(\.createdDate)]
                )
                let result = try context.fetch(descriptor)
                return result
            } else {
                let descriptor: FetchDescriptor<Folder> = .init(
                    sortBy: [.init(\.createdDate)]
                )
                let result = try context.fetch(descriptor)
                return result.filter { $0.parentFolder == nil }
            }
        } catch {
            return []
        }
    }
    
    public func update(folder: Folder) -> Void {
        do {
            try context.save()
            print("Successfully updated folder: \(folder.name ?? "Unknown")")
        } catch {
            print("Failed to update folder: \(error)")
        }
    }
    
    public func delete(folder: Folder) -> Void {
        do {
            context.delete(folder)
            try context.save()
        } catch {
        }
    }
    
    public func save(_ folder: Folder) {
        do {
            context.insert(folder)
            try context.save()
        } catch {
        }
    }
}

public class FolderClientTest: FolderClient {
    public func create(parentFolder: Folder?, name: String) -> Folder {
        fatalError()
    }
    
    public func fetches(parentFolder: Folder?) -> [Folder] {
        fatalError()
    }
    
    public func update(folder: Folder) {
        fatalError()
    }
    
    public func delete(folder: Folder) {
        fatalError()
    }
}
