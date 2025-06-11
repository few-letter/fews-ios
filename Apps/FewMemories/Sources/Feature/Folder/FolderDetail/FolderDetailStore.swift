//
//  PlotListStore.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FolderDetailStore {
    @ObservableState
    public struct State: Equatable {
        public let folderType: FolderType
        
        public var folderTypeListCells: IdentifiedArrayOf<FolderTypeListCellStore.State>
        public var plotListCells: IdentifiedArrayOf<PlotListCellStore.State>
        
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
        case fetched([Plot])
        
        case folderTypeListCell(IdentifiedActionOf<FolderTypeListCellStore>)
        case plotListCell(IdentifiedActionOf<PlotListCellStore>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case requestAddPlot(Plot)
            case requestAddFolder(Folder)
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
                return .none
                
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
                return .send(.fetched(plots))
                
            case .fetched(let plots):
                state.plotListCells = .init(uniqueElements: plots.map { plot in
                    return .init(plot: plot)
                })
                return .none
                
            case .plotListCell(.element(id: let id, action: .delegate(let action))):
                switch action {
                case .tapped:
                    if let plot = state.plotListCells[id: id]?.plot {
                        return .send(.delegate(.requestAddPlot(plot)))
                    }
                }
                return .none
                
            case .plotListCell, .delegate, .folderTypeListCell:
                return .none
            }
        }
        .forEach(\.plotListCells, action: \.plotListCell) {
            PlotListCellStore()
        }
        .forEach(\.folderTypeListCells, action: \.folderTypeListCell) {
            FolderTypeListCellStore()
        }
    }
}
