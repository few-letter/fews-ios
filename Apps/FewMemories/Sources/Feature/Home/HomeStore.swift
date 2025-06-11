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
        case folderDetail(FolderDetailStore)
        case addPlot(AddPlotStore)
        case setting(SettingStore)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        
        public var folder: FolderStore.State
        public var addFolder: AddFolderStore.State?
        
        @Shared(.appStorage("currentFolderID")) var currentFolderID: String? = nil
        
        public init(
            path: StackState<Path.State> = .init(),
            folder: FolderStore.State = .init(),
            addFolder: AddFolderStore.State? = nil,
        ) {
            self.path = path
            self.folder = folder
            self.addFolder = addFolder
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case dismiss
        
        case path(StackActionOf<Path>)
        case folder(FolderStore.Action)
        case addFolder(AddFolderStore.Action)
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
                return .none
                
            case .dismiss:
                state.addFolder = nil
                return .none
                
            case .path(.element(id: let id, action: .folderDetail(.delegate(let action)))):
                switch action {
                case .requestAddPlot(let plot):
                    state.path.append(.addPlot(.init(plot: plot)))
                    return .none
                case .requestAddFolder(let folder):
                    state.addFolder = .init(parentFolder: folder, name: "")
                    return .none
                }
                
            case .folder(.delegate(let action)):
                switch action {
                case .requestSetting:
                    state.path.append(.setting(.init()))
                case .requestPlot(let folderType):
                    state.path.append(.folderDetail(.init(folderType: folderType)))
                case .requestAddPlot:
                    let plot = plotClient.create(folder: nil)
                    state.path.append(.addPlot(.init(plot: plot)))
                case .requestAddFolder:
                    state.addFolder = .init(parentFolder: nil, name: "")
                }
                return .none
                
            case .addFolder(.delegate(let action)):
                switch action {
                case .confirm(let parentFolder, let name):
                    let _ = folderClient.create(parentFolder: parentFolder, name: name)
                    return .none
                case .dismiss:
                    break
                }
                state.addFolder = nil
                return .none
                
            case .path, .folder, .addFolder:
                return .none
            }
        }
        Scope(state: \.folder, action: \.folder) {
            FolderStore()
        }
        .ifLet(\.addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .forEach(\.path, action: \.path)
    }
}
