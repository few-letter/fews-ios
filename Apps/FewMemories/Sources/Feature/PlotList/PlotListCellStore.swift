//
//  PlotListCellStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PlotListCellStore {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        let plot: Plot
    }
    
    enum Action: Equatable {
        case tapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapped:
                return .none
            }
        }
    }
}
