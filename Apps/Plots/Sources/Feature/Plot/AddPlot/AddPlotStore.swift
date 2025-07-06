//
//  EditPlotStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation
import SwiftData
import ComposableArchitecture

@Reducer
public struct AddPlotStore {
    @ObservableState
    public struct State: Equatable {
        public var plot: PlotModel
        
        public init(plot: PlotModel) {
            self.plot = plot
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        
        case confirmButtonTapped
        case cancelButtonTapped
        
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case requestConfirm
            case requestCancel
        }
    }
    
    public init() {}
    
    @Dependency(\.plotClient) private var plotClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                plotClient.createOrUpdate(plot: state.plot)
                return .none
            case .onAppear:
                return .none
                
            case .confirmButtonTapped:
                plotClient.createOrUpdate(plot: state.plot)
                return .send(.delegate(.requestConfirm))
                
            case .cancelButtonTapped:
                return .send(.delegate(.requestCancel))
                
            case .delegate:
                return .none
            }
        }
    }
}
