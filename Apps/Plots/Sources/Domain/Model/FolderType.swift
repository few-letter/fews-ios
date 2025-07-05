//
//  FolderType.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

import Foundation

public enum FolderType: Equatable, Identifiable {
    case temporary(name: String, plots: [Plot])
    case folder(Folder)
    
    public var id: FolderID? {
        switch self {
        case .temporary: return nil
        case .folder(let folder): return folder.id
        }
    }
    
    public var folder: Folder? {
        switch self {
        case .temporary: return nil
        case .folder(let folder): return folder
        }
    }
    
    public var plots: [Plot] {
        switch self {
        case .temporary(_, let plots): return plots
        case .folder(let folder): return folder.plots ?? []
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
                items.append("\(memosCount) \(memoText)")
            }
            
            if items.count == 1 {
                return items[0] + " will be deleted."
            } else if items.count == 2 {
                return items[0] + " and " + items[1] + " will be deleted."
            } else {
                let firstPart = items.dropLast().joined(separator: ", ")
                let lastPart = items.last!
                return firstPart + ", and " + lastPart + " will be deleted."
            }
        }
    }
    
    private var childCount: Int {
        switch self {
        case .temporary:
            return 0
        case .folder(let folder):
            let subfolders = folder.folders ?? []
            return subfolders.count + subfolders.map { FolderType.folder($0).childCount }.reduce(0, +)
        }
    }
    
    private var totalPlotsCount: Int {
        switch self {
        case .temporary(_, let plots):
            return plots.count
        case .folder(let folder):
            let subfolders = folder.folders ?? []
            let subfoldersPlots = subfolders.map { FolderType.folder($0).totalPlotsCount }.reduce(0, +)
            return (folder.plots?.count ?? 0) + subfoldersPlots
        }
    }
}
