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
        public var plots: [Plot]
        @Presents public var addFolder: AddFolderStore.State?
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init(
            folderType: FolderType
        ) {
            self.folderType = folderType
            
            if let folders = folderType.folder?.folders  {
                self.folderTypes = folders.map { folder in
                    return .folder(folder)
                }
            } else {
                self.folderTypes = []
            }
            self.plots = folderType.plots
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case addFolderButtonTapped(Folder)
        case addPlotButtonTapped
        case delete(IndexSet)
        case refresh
        
        case fetch
        case fetched([Folder], [Plot])
        
        case folderTypeListCellTapped(FolderType)
        case folderTypeListCellDeleteTapped(FolderID)
        case plotListCellTapped(Plot)
        case addFolder(PresentationAction<AddFolderStore.Action>)
        case alert(PresentationAction<Alert>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case requestAddPlot(Plot)
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
                state.addFolder = .init(parentFolder: folder, name: "")
                return .none
                
            case .addPlotButtonTapped:
                let plot = plotClient.create(folder: state.folderType.folder)
                return .send(.delegate(.requestAddPlot(plot)))
                
            case let .delete(indexSet):
                let plotsToDelete = indexSet.map { state.plots[$0] }
                for plot in plotsToDelete {
                    plotClient.delete(plot: plot)
                }
                return .send(.refresh)
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                let plots: [Plot] = plotClient.fetches(folder: state.folderType.folder)
                var folders: [Folder] = []
                if let folder = state.folderType.folder {
                    folders = folderClient.fetches(parentFolder: folder)
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
                case .confirm(let folder, let name):
                    let _ = folderClient.create(parentFolder: folder, name: name)
                    state.addFolder = nil
                    return .send(.fetch)
                case .dismiss:
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
