//
//  FolderStore.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
public struct FolderStore {
    @ObservableState
    public struct State: Equatable {
        public var folderTypes: [FolderType]
        
        @Presents public var addFolder: AddFolderStore.State?
        @Presents public var alert: AlertState<Action.AlertAction>?
        
        public init(
            folderTypes: [FolderType] = []
        ) {
            self.folderTypes = folderTypes
        }
    }
    
    public enum Action {
        case onAppear
        
        case settingButtonTapped
        case addFolderButtonTapped
        case addPlotButtonTapped
        case editFolderButtonTapped(FolderModel)
        case refresh
        
        case fetch
        case fetched([FolderModel], [PlotModel])
        
        case folderTypeListCellTapped(FolderType)
        case folderTypeListCellDeleteTapped(FolderID)
        case addFolder(PresentationAction<AddFolderStore.Action>)
        case alert(PresentationAction<AlertAction>)
        
        public enum AlertAction: Equatable {
            case requestDelete(FolderID)
        }
        
        case delegate(Delegate)
        public enum Delegate {
            case requestPlot(FolderType)
            case requestAddPlot
            case requestSettings
            case requestDelete(FolderID)
        }
    }
    
    public init() {}
    
    @Dependency(\.folderClient) var folderClient
    @Dependency(\.plotClient) var plotClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetch)
                
            case .settingButtonTapped:
                return .send(.delegate(.requestSettings))
                
            case .addFolderButtonTapped:
                state.addFolder = .init(folder: .init())
                return .none
                
            case .addPlotButtonTapped:
                return .send(.delegate(.requestAddPlot))
                
            case .editFolderButtonTapped(let folder):
                state.addFolder = .init(folder: folder)
                return .none
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                let rootFolders = folderClient.fetches(parentFolder: nil)
                let plots = plotClient.fetches()
                return .run { send in
                    await send(.fetched(rootFolders, plots))
                }
                
            case .fetched(let folders, let plots):
                let folderModels = folders
                let plotModels = plots
                
                var folderTypes: [FolderType] = [.temporary(name: "All", plots: plotModels)]
                folderTypes += folderModels.map { .folder($0) }
                state.folderTypes = folderTypes
                return .none
                
            case .folderTypeListCellTapped(let folderType):
                return .send(.delegate(.requestPlot(folderType)))
                
            case .folderTypeListCellDeleteTapped(let folderID):
                guard let folderType = state.folderTypes.first(where: { $0.id == folderID }) else { return .none }
                
                state.alert = .init(
                    title: {
                        TextState("Delete Folder")
                    },
                    actions: {
                        ButtonState(role: .destructive, action: .requestDelete(folderID)) {
                            TextState("Delete")
                        }
                    },
                    message: { TextState(folderType.deleteMessage) })
                
                return .none
                
            case .addFolder(.presented(.delegate(let action))):
                switch action {
                case .requestConfirm:
                    state.addFolder = nil
                    return .send(.fetch)
                case .requestCancel:
                    state.addFolder = nil
                    return .none
                }
                
            case .alert(.presented(.requestDelete(let folderID))):
                return .send(.delegate(.requestDelete(folderID)))
                
            case .delegate, .alert, .addFolder:
                return .none
            }
        }
        .ifLet(\.$addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
