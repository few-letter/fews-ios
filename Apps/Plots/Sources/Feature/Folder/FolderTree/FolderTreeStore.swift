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
        
        public var folderTypeListCells: IdentifiedArrayOf<FolderTypeListCellStore.State>
        public var plotListCells: IdentifiedArrayOf<PlotListCellStore.State>
        @Presents public var addFolder: AddFolderStore.State?
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init(
            folderType: FolderType
        ) {
            self.folderType = folderType
            
            if let folders = folderType.folder?.folders  {
                self.folderTypeListCells = .init(uniqueElements: folders.map { folder in
                    return .init(folderType: .folder(folder))
                })
            } else {
                self.folderTypeListCells = []
            }
            self.plotListCells = .init(uniqueElements: folderType.plots.map { plot in
                return .init(plot: plot)
            })
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
        
        case folderTypeListCell(IdentifiedActionOf<FolderTypeListCellStore>)
        case plotListCell(IdentifiedActionOf<PlotListCellStore>)
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
                for index in indexSet {
                    let cell = state.plotListCells.remove(at: index)
                    plotClient.delete(plot: cell.plot)
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
                state.plotListCells = .init(
                    uniqueElements: plots.map { plot in
                        return .init(plot: plot)
                })
                state.folderTypeListCells = .init(
                    uniqueElements: folders.map { folder in
                        return .init(folderType: .folder(folder))
                    }
                )
                return .none
                
            case .folderTypeListCell(.element(id: let id, action: .delegate(let action))):
                guard let folderType = state.folderTypeListCells[id: id]?.folderType else { return .none }
                
                switch action {
                case .tapped:
                    return .send(.delegate(.requestFolderTree(folderType)))
                    
                case .requestDelete(let folderID):
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
                }
                
            case .plotListCell(.element(id: let id, action: .delegate(let action))):
                switch action {
                case .tapped:
                    if let plot = state.plotListCells[id: id]?.plot {
                        return .send(.delegate(.requestAddPlot(plot)))
                    }
                }
                return .none
                
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
                    if case let .folder(folder) = state.folderTypeListCells[id: folderID]?.folderType {
                        folderClient.delete(folder: folder)
                        return .send(.fetch)
                    }
                    return .none
                }
                
            case .plotListCell, .delegate, .folderTypeListCell, .alert, .addFolder:
                return .none
            }
        }
        
        .ifLet(\.$addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.plotListCells, action: \.plotListCell) {
            PlotListCellStore()
        }
        .forEach(\.folderTypeListCells, action: \.folderTypeListCell) {
            FolderTypeListCellStore()
        }
    }
}
