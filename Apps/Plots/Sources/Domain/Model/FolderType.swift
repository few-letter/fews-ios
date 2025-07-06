//
//  FolderType.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

import Foundation
import SwiftData

public enum FolderType: Identifiable {
    case temporary(name: String, plots: [PlotModel])
    case folder(FolderModel)
    
    public var id: FolderID? {
        switch self {
        case .temporary: return nil
        case .folder(let folder): return folder.id
        }
    }
    
    public var folder: FolderModel? {
        switch self {
        case .temporary: return nil
        case .folder(let folder): return folder
        }
    }
    
    public var plots: [PlotModel] {
        switch self {
        case .temporary(_, let plots): return plots
        case .folder(let folder): return folder.folder?.plots?.compactMap { .init(from: $0) } ?? []
        }
    }
    
    public var name: String {
        switch self {
        case .temporary(let name, _): return name
        case .folder(let folder): return folder.name ?? ""
        }
    }
    
    public var count: Int {
        self.plots.count
    }
}

// MARK: - Equatable
extension FolderType: Equatable {
    public static func == (lhs: FolderType, rhs: FolderType) -> Bool {
        switch (lhs, rhs) {
        case (.temporary(let lName, let lPlots), .temporary(let rName, let rPlots)):
            return lName == rName && lPlots == rPlots
        case (.folder(let lFolder), .folder(let rFolder)):
            return lFolder.id == rFolder.id
        default:
            return false
        }
    }
}

extension FolderType {
    public var deleteMessage: String {
        switch self {
        case .temporary:
            return "Can't delete this folder"
        case .folder:
            let folderName = self.name
            let subfoldersCount = self.childCount
            let memosCount = self.totalPlotsCount
            
            var items: [String] = ["the '\(folderName)' folder"]
            
            if subfoldersCount > 0 {
                let subfolderText = subfoldersCount == 1 ? "subfolder" : "subfolders"
                items.append("its \(subfoldersCount) \(subfolderText)")
            }
            
            if memosCount > 0 {
                let memoText = memosCount == 1 ? "memo" : "memos"
                items.append("its \(memosCount) \(memoText)")
            }
            
            let itemsText = items.joined(separator: ", ")
            return "Are you sure you want to delete \(itemsText)?"
        }
    }
}

extension FolderType {
    public var childCount: Int {
        switch self {
        case .temporary:
            return 0
        case .folder(let folder):
            let subfolders = folder.folders
            return subfolders.count + subfolders.map { FolderType.folder(FolderModel(from: $0)).childCount }.reduce(0, +)
        }
    }

    private var totalPlotsCount: Int {
        switch self {
        case .temporary(_, let plots):
            return plots.count
        case .folder(let folder):
            let subfolders = folder.folders
            let subfoldersPlots = subfolders.map { FolderType.folder(FolderModel(from: $0)).totalPlotsCount }.reduce(0, +)
            return (folder.folder?.plots?.count ?? 0) + subfoldersPlots
        }
    }
}
