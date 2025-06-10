//
//  PlotListStore.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct PlotListStore {
    @ObservableState
    public struct State: Equatable {
        let folder: Folder
        var searchQuery: String = ""
        var plotListCells: IdentifiedArrayOf<PlotListCellStore.State> = []
        var filteredPlotListCells: IdentifiedArrayOf<PlotListCellStore.State> = []
        @Presents var plot: PlotStore.State?
        
        public init(folder: Folder) {
            self.folder = folder
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case onAppear
        case refresh
        case addButtonTapped
        case fetchResponse([Plot])
        case search(String)
        case delete(IndexSet)
        
        case plotListCell(IdentifiedActionOf<PlotListCellStore>)
        case plot(PresentationAction<PlotStore.Action>)
    }
    
    @Dependency(\.plotClient) var plotClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear, .refresh:
                let plots = plotClient.fetches(folder: state.folder)
                return .send(.fetchResponse(plots))
                
            case .addButtonTapped:
                let plot = plotClient.create(folder: state.folder)
                state.plot = PlotStore.State(plot: plot)
                return .none
                
            case let .search(searchQuery):
                state.searchQuery = searchQuery
                guard !searchQuery.isEmpty else {
                    state.filteredPlotListCells = state.plotListCells
                    return .none
                }
                
                state.filteredPlotListCells = state.plotListCells.filter({
                    $0.plot.title?.lowercased().contains(searchQuery.lowercased()) == true ||
                    $0.plot.content?.lowercased().contains(searchQuery.lowercased()) == true
                })
                
                return .none
                
            case let .fetchResponse(plots):
                state.plotListCells = []
                plots.forEach({ plot in
                    state.plotListCells.append(PlotListCellStore.State(id: UUID(), plot: plot))
                })
                state.filteredPlotListCells = state.plotListCells
                return .none
                
            case let .delete(indexSet):
                for index in indexSet {
                    let plot = state.plotListCells[index].plot
                    plotClient.delete(plot: plot)
                }
                return .send(.refresh)
                
            case let .plotListCell(.element(id: id, action: .tapped)):
                if let plot = state.plotListCells.first(where: { $0.id == id })?.plot {
                    state.plot = PlotStore.State(plot: plot)
                }
                return .none
                
            case .plotListCell, .plot:
                return .none
            }
        }
        .forEach(\.plotListCells, action: \.plotListCell) {
            PlotListCellStore()
        }
        .ifLet(\.$plot, action: \.plot) {
            PlotStore()
        }
    }
} 
