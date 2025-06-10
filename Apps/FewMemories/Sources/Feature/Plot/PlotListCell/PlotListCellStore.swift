//
//  PlotListCellStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct PlotListCellStore {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public let plot: Plot
    }
    
    public enum Action: Equatable {
        case tapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapped:
                return .none
            }
        }
    }
}
