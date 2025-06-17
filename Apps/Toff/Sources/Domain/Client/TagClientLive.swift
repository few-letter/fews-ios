//
//  TagClientLive.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import SwiftData

public class TagClientLive: TagClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
        self.context.autosaveEnabled = false
    }
    
    public func create() -> Tag {
        return .init(id: .init(), hex: "", name: "")
    }
    
    public func fetches() -> [Tag] {
        do {
            let descriptor: FetchDescriptor<Tag> = .init()
            let result = try context.fetch(descriptor)
            return result
        } catch {
            return []
        }
    }
    
    public func update(tag: Tag) {
        do {
            try context.save()
        } catch {
            print("Failed to update ticker: \(error)")
        }
    }
    
    public func delete(tag: Tag) {
        do {
            context.delete(tag)
            try context.save()
        } catch {

        }
    }
}

public class TagClientTest: TagClient {
    public func create() -> Tag {
        fatalError()
    }
    
    public func fetches() -> [Tag] {
        fatalError()
    }
    
    public func update(tag: Tag) {
        fatalError()
    }
    
    public func delete(tag: Tag) {
        fatalError()
    }
    
}
