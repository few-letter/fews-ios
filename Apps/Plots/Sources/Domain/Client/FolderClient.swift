//
//  FolderClient.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol FolderClient {
    @discardableResult
    func createOrUpdate(folder: FolderModel) -> FolderModel
    func fetches(parentFolder: FolderModel?) -> [FolderModel]
    func delete(folder: FolderModel)
}

private struct FolderClientKey: TestDependencyKey {
    static var testValue: any FolderClient = FolderClientTest()
}

extension DependencyValues {
    var folderClient: any FolderClient {
        get { self[FolderClientKey.self] }
        set { self[FolderClientKey.self] = newValue }
    }
}

public struct FolderClientTest: FolderClient {
    public func createOrUpdate(folder: FolderModel) -> FolderModel {
        return folder
    }
    
    public func fetches(parentFolder: FolderModel?) -> [FolderModel] {
        return []
    }
    
    public func delete(folder: FolderModel) {
        // Test implementation
    }
}
