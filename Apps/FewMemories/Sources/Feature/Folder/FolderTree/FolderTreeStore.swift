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
        case alert(PresentationAction<Alert>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case requestAddPlot(Plot)
            case requestAddFolder(Folder)
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
                return .send(.delegate(.requestAddFolder(folder)))
                
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
                let plots = plotClient.fetches(folder: state.folderType.folder)
                let folders = folderClient.fetches(parentFolder: state.folderType.folder)
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
                    let title = "Delete Folder"
                    let message = "The \(folderType.name) folder and \(folderType.count) memos will be deleted."
                    state.alert = AlertState(
                        title: {
                            TextState(title)
                        },
                        actions: {
                            ButtonState(role: .cancel) {
                                TextState("Cancel")
                            }
                            ButtonState(role: .destructive, action: .requestDelete(folderID)) {
                                TextState("Confirm")
                            }
                        },
                        message: { TextState(message) }
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
                
            case .alert(.presented(let action)):
                switch action {
                case .requestDelete(let folderID):
                    if case let .folder(folder) = state.folderTypeListCells[id: folderID]?.folderType {
                        folderClient.delete(folder: folder)
                        return .send(.fetch)
                    }
                    return .none
                }
                
            case .plotListCell, .delegate, .folderTypeListCell, .alert:
                return .none
            }
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
