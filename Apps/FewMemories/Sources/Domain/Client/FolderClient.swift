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
    func create(parentFolder: Folder?, name: String) -> Folder
    func fetchRoots() -> [Folder]
    func fetches(parentFolder: Folder) -> [Folder]
    func update(folder: Folder) -> Void
    func delete(folder: Folder) -> Void
}

private struct FolderClientKey: DependencyKey {
    static let liveValue: any FolderClient = FolderClientTest()
}

extension DependencyValues {
    var folderClient: any FolderClient {
        get { self[FolderClientKey.self] }
        set { self[FolderClientKey.self] = newValue }
    }
}
