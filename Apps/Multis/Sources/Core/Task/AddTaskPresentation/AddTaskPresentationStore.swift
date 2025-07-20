//
//  AddTaskPresentationStore.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddTaskPresentationStore {
    @ObservableState
    public struct State {
        @Presents public var addTaskNavigation: AddTaskNavigationStore.State? = nil
        
        public init() {
            
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case addTaskNavigation(PresentationAction<AddTaskNavigationStore.Action>)
        
        case delegate(Delegate)
        public enum Delegate {
            case dismiss
        }
    }
    
    public init() {}
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .addTaskNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestSaved:
                    state.addTaskNavigation = nil
                    return .send(.delegate(.dismiss))
                case .dismiss:
                    state.addTaskNavigation = nil
                    return .send(.delegate(.dismiss))
                }
                
            case .addTaskNavigation, .delegate:
                return .none
            }
        }
        .ifLet(\.$addTaskNavigation, action: \.addTaskNavigation) {
            AddTaskNavigationStore()
        }
    }
}
