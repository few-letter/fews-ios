//
//  PlotListStore.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FolderTreeStore {
    @ObservableState
    public struct State: Equatable {
        public let folderType: FolderType
        
        public var folderTypes: [FolderType]
        public var plots: [PlotModel]
        @Presents public var addFolder: AddFolderStore.State?
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init(
            folderType: FolderType
        ) {
            self.folderType = folderType
            
            if let folders = folderType.folder?.folders  {
                self.folderTypes = folders.map { folder in
                    return .folder(.init(from: folder))
                }
            } else {
                self.folderTypes = []
            }
            self.plots = folderType.plots
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case addFolderButtonTapped(FolderModel)
        case addPlotButtonTapped
        case editFolderButtonTapped(FolderModel)
        case delete(IndexSet)
        case refresh
        
        case fetch
        case fetched([FolderModel], [PlotModel])
        
        case folderTypeListCellTapped(FolderType)
        case folderTypeListCellDeleteTapped(FolderID)
        case plotListCellTapped(PlotModel)
        case addFolder(PresentationAction<AddFolderStore.Action>)
        case alert(PresentationAction<Alert>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case requestAddPlot(PlotModel)
            case requestFolderTree(FolderType)
        }
        
        @CasePathable
        public enum Alert: Equatable {
            case requestDelete(FolderID)
        }
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
                
            case .addFolderButtonTapped(let folder):
                state.addFolder = .init(folder: .init(parentFolder: folder.folder))
                return .none
                
            case .addPlotButtonTapped:
                let newPlot = PlotModel.init(folder: state.folderType.folder?.folder)
                let plot = plotClient.createOrUpdate(plot: newPlot)
                return .send(.delegate(.requestAddPlot(plot)))
                
            case .editFolderButtonTapped(let folder):
                state.addFolder = .init(folder: folder)
                return .none
                
            case let .delete(indexSet):
                let plotsToDelete = indexSet.map { state.plots[$0] }
                for plot in plotsToDelete {
                    plotClient.delete(plot: plot)
                }
                return .send(.refresh)
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                let plots: [PlotModel]
                let folders: [FolderModel]
                if let folder = state.folderType.folder {
                    plots = plotClient.fetches(folder: folder)
                    folders = folderClient.fetches(parentFolder: folder)
                } else {
                    plots = plotClient.fetches()
                    folders = []
                }
                return .send(.fetched(folders, plots))
                
            case .fetched(let folders, let plots):
                state.plots = plots
                state.folderTypes = folders.map { folder in
                    return .folder(folder)
                }
                return .none
                
            case .folderTypeListCellTapped(let folderType):
                return .send(.delegate(.requestFolderTree(folderType)))
                
            case .folderTypeListCellDeleteTapped(let folderID):
                guard let folderType = state.folderTypes.first(where: { $0.id == folderID }) else { return .none }
                
                state.alert = AlertState(
                    title: {
                        TextState("Delete Folder")
                    },
                    actions: {
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                        ButtonState(role: .destructive, action: .requestDelete(folderID)) {
                            TextState("Confirm")
                        }
                    },
                    message: { TextState(folderType.deleteMessage) }
                )
                return .none
                
            case .plotListCellTapped(let plot):
                return .send(.delegate(.requestAddPlot(plot)))
                
            case .addFolder(.presented(.delegate(let action))):
                switch action {
                case .requestConfirm:
                    state.addFolder = nil
                    return .send(.fetch)
                case .requestCancel:
                    state.addFolder = nil
                    return .none
                }
                
            case .alert(.presented(let action)):
                switch action {
                case .requestDelete(let folderID):
                    if case let .folder(folder) = state.folderTypes.first(where: { $0.id == folderID }) {
                        folderClient.delete(folder: folder)
                        return .send(.fetch)
                    }
                    return .none
                }
                
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
