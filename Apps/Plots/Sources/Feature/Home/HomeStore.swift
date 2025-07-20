//
//  HomeStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import ComposableArchitecture
import Foundation
import SwiftData
import Feature_Common

@Reducer
public struct HomeStore {
    @Reducer
    public enum Path {
        case folderTree(FolderTreeStore)
        case addPlot(AddPlotStore)
        case settings(SettingsStore)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        
        public var folder: FolderStore.State
        
        @Shared(.appStorage("currentFolderID")) var currentFolderID: String? = nil
        
        public init(
            path: StackState<Path.State> = .init(),
            folder: FolderStore.State = .init(),
        ) {
            self.path = path
            self.folder = folder
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case path(StackActionOf<Path>)
        case folder(FolderStore.Action)
    }
    
    @Dependency(\.plotClient) var plotClient
    @Dependency(\.folderClient) var folderClient
    @Dependency(\.adClient) var adClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .path(.element(id: _, action: .folderTree(.delegate(let action)))):
                switch action {
                case .requestAddPlot(let plot):
                    state.path.append(.addPlot(.init(plot: plot)))
                    return .none
                case .requestFolderTree(let folderType):
                    state.path.append(.folderTree(.init(folderType: folderType)))
                    return .none
                }
                
            case .folder(.delegate(let action)):
                switch action {
                case .requestPlot(let folderType):
                    state.path.append(.folderTree(.init(folderType: folderType)))
                    return .none
                case .requestAddPlot(let plot):
                    state.path.append(.addPlot(.init(plot: plot)))
                    return .none
                case .requestSettings:
                    state.path.append(.settings(.init()))
                    return .none
                }
                
            case .path, .folder:
                return .none
            }
        }
        
        Scope(state: \.folder, action: \.folder) {
            FolderStore()
        }
        
        .forEach(\.path, action: \.path)
    }
}
