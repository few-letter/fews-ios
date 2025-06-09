//
//  HomeStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import ComposableArchitecture
import Foundation

enum HomeScene: Hashable {
    case home
    case plot
    case setting
}

@Reducer
struct HomeStore {
    @ObservableState
    struct State: Equatable {
        var path: [HomeScene] = []
        
        var searchQuery: String = ""
        
        var plotListCells: IdentifiedArrayOf<PlotListCellStore.State> = []
        var filteredPlotListCells: IdentifiedArrayOf<PlotListCellStore.State> = []
        @Presents var plot: PlotStore.State?
        @Presents var setting: SettingStore.State?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case refresh
        case addButtonTapped
        case settingButtonTapped
        case fetchResponse([Plot])
        case search(String)
        case delete(IndexSet)
        
        case plotListCell(IdentifiedActionOf<PlotListCellStore>)
        case plot(PresentationAction<PlotStore.Action>)
        case setting(PresentationAction<SettingStore.Action>)
    }
    
    @Dependency(\.plotClient) var plotClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .refresh:
                return .send(.fetchResponse(plotClient.fetches()))
                
            case .addButtonTapped:
                state.plot = PlotStore.State(plot: plotClient.createPlot())
                state.path.append(.plot)
                return .none
                
            case .settingButtonTapped:
                state.setting = SettingStore.State()
                state.path.append(.setting)
                return .none
                
            case let .search(searchQuery):
                state.searchQuery = searchQuery
                guard searchQuery.isEmpty == false else {
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
                    state.path.append(.plot)
                }
                return .none
                
            case .plotListCell:
                return .none
                
            case .plot, .setting:
                return .none
            }
        }
        .forEach(\.plotListCells, action: \.plotListCell) {
            PlotListCellStore()
        }
        .ifLet(\.$plot, action: \.plot) {
            PlotStore()
        }
        .ifLet(\.$setting, action: \.setting) {
            SettingStore()
        }
    }
}
