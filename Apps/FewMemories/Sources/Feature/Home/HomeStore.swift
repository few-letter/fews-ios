//
//  HomeStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
public struct HomeStore {
    @Reducer
    public enum Path {
        case plotList(PlotListStore)
        case setting(SettingStore)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        
        public var folderTypeListCells: IdentifiedArrayOf<FolderTypeListCellStore.State>
        public var folderDeleteAlert: Folder?
        public var addFolder: AddFolderStore.State?
        
        @Shared(.appStorage("currentFolderID")) var currentFolderID: String? = nil
        
        public init(
            path: StackState<Path.State> = .init(),
            folderTypeListCells: IdentifiedArrayOf<FolderTypeListCellStore.State> = [],
            folderDeleteAlert: Folder? = nil,
            addFolder: AddFolderStore.State? = nil,
        ) {
            self.path = path
            self.folderTypeListCells = folderTypeListCells
            self.folderDeleteAlert = folderDeleteAlert
            self.addFolder = addFolder
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case dismiss
        case deleteFolder(Folder)
        case settingButtonTapped
        case addFolderButtonTapped
        case refresh
        
        case fetch
        case fetched([Folder], [Plot])
        
        case path(StackActionOf<Path>)
        case addFolder(AddFolderStore.Action)
        case folderTypeListCell(IdentifiedActionOf<FolderTypeListCellStore>)
    }
    
    @Dependency(\.plotClient) var plotClient
    @Dependency(\.folderClient) var folderClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .send(.fetch)
                
            case .deleteFolder(let folder):
                self.folderClient.delete(folder: folder)
                return .none
                
            case .settingButtonTapped:
                state.path.append(.setting(.init()))
                return .none
                
            case .addFolderButtonTapped:
                state.addFolder = .init(name: "")
                return .none
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                let folders: [Folder] = folderClient.fetches()
                let plots: [Plot] = plotClient.fetches(folder: nil)
                return .send(.fetched(folders, plots))
                
            case .fetched(let folders, let plots):
                var cells: [FolderTypeListCellStore.State] = [.init(folderType: .temporary(name: "all", plots: plots))]
                cells += folders.map { .init(folderType: .folder($0)) }
                state.folderTypeListCells = .init(uniqueElements: cells)
                return .none
                
            case .addFolder(.delegate(let action)):
                switch action {
                case .confirm(let name):
                    let folder = folderClient.create(name: name)
                    state.folderTypeListCells.append(.init(folderType: .folder(folder)))
                    return .none
                    
                case .dismiss:
                    break
                }
                state.addFolder = nil
                return .none
                
            case .dismiss:
                state.addFolder = nil
                return .none
                
            case .folderTypeListCell(.element(id: let id, action: .delegate(let action))):
                guard let folderType = state.folderTypeListCells[id: id]?.folderType else { return .none }
                
                switch action {
                case .tapped:
                    state.path.append(.plotList(.init(folderType: folderType)))
                    return .none
                    
                case .delete:
                    state.folderDeleteAlert = folderType.folder
                    return .none
                }
                
            case .folderTypeListCell, .path, .addFolder:
                return .none
            }
        }
        .ifLet(\.addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .forEach(\.folderTypeListCells, action: \.folderTypeListCell) {
            FolderTypeListCellStore()
        }
        .forEach(\.path, action: \.path)
    }
}
