//
//  FolderType.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

public enum FolderType: Equatable {
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
