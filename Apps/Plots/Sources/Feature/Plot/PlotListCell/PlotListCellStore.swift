//
//  PlotListCellStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation
import ComposableArchitecture
import SwiftData

@Reducer
public struct PlotListCellStore {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let plot: Plot
        
        public var id: PersistentIdentifier {
            plot.id
        }
    }
    
    public enum Action: Equatable {
        case tapped
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case tapped
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapped:
                return .send(.delegate(.tapped))
                
            case .delegate:
                return .none
            }
        }
    }
}
