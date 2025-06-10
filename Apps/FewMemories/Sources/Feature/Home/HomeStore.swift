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
        public var path = StackState<Path.State>()
        
        var folderToDelete: Folder?
        var isShowingDeleteAlert = false
        var deleteAlertMessage = ""
        
        public var folderListCells: IdentifiedArrayOf<FolderListCellStore.State> = []
        public var folderDeleteAlert: Folder?
        
        public var addFolder: AddFolderStore.State?
        @Shared(.appStorage("currentFolderID")) var currentFolderID: String? = nil
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case dismiss
        case deleteFolder(Folder)
        case settingButtonTapped
        case addFolderButtonTapped
        
        case path(StackActionOf<Path>)
        case addFolder(AddFolderStore.Action)
        case folderListCell(IdentifiedActionOf<FolderListCellStore>)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.plotClient) var plotClient
    @Dependency(\.folderClient) var folderClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .deleteFolder(let folder):
                self.folderClient.delete(folder: folder)
                return .none
                
            case .settingButtonTapped:
                state.path.append(.setting(.init()))
                return .none
                
            case .addFolderButtonTapped:
                state.addFolder = .init(name: "")
                return .none
                
            case .addFolder(.delegate(let action)):
                switch action {
                case .confirm(let name):
                    let folder = folderClient.create(name: name)
                    state.folderListCells.append(.init(folder: folder))
                    return .none
                    
                case .dismiss:
                    state.addFolder = nil
                    return .none
                }
                
            case .dismiss:
                state.addFolder = nil
                return .none
                
            case .folderListCell(.element(id: let id, action: .delegate(let action))):
                guard let folder = state.folderListCells[id: id]?.folder else { return .none }
                
                switch action {
                case .tapped:
                    state.path.append(.plotList(.init(folder: folder)))
                    return .none
                    
                case .delete:
                    state.folderDeleteAlert = folder
                    return .none
                }
                
            case .folderListCell, .path, .addFolder:
                return .none
            }
        }
        .ifLet(\.addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .forEach(\.folderListCells, action: \.folderListCell) {
            FolderListCellStore()
        }
        .forEach(\.path, action: \.path)
    }
}
