//
//  FolderClientLive.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import SwiftData

public class FolderClientLive: FolderClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public func create(name: String) -> Folder {
        let folder = Folder(name: name)
        self.save(folder)
        return folder
    }
    
    public func fetches() -> [Folder] {
        do {
            let descriptor = FetchDescriptor<Folder>(
                sortBy: [.init(\.createdDate)]
            )
            let result = try context.fetch(descriptor)
            return result
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
    public func create(name: String) -> Folder {
        fatalError()
    }
    
    public func fetches() -> [Folder] {
        fatalError()
    }
    
    public func update(folder: Folder) {
        fatalError()
    }
    
    public func delete(folder: Folder) {
        fatalError()
    }
}
