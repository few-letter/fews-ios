//
//  FolderListCellStore.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import Foundation
import ComposableArchitecture

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

@Reducer
public struct FolderTypeListCellStore {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let folderType: FolderType
        
        public var id: FolderID? { return folderType.id }
        
        public init(folderType: FolderType) {
            self.folderType = folderType
        }
    }
    
    public enum Action: Equatable {
        case tapped
        case deleteButtonTapped
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case tapped
            case delete
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .tapped:
                return .send(.delegate(.tapped))
                
            case .deleteButtonTapped:
                return .send(.delegate(.delete))
                
            case .delegate:
                return .none
            }
        }
    }
} 
