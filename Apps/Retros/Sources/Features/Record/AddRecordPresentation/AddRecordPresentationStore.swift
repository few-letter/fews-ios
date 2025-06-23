//
//  AddRecordPresentation.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddRecordPresentationStore {
    @ObservableState
    public struct State {
        @Presents public var addRecordNavigation: AddRecordNavigationStore.State? = nil
        
        public init() {
            
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case addRecordNavigation(PresentationAction<AddRecordNavigationStore.Action>)
        
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
                
            case .addRecordNavigation(.presented(.delegate(let action))):
                switch action {
                case .requestSaved:
                    return .send(.delegate(.dismiss))
                case .dismiss:
                    return .send(.delegate(.dismiss))
                }
                
            case .addRecordNavigation, .delegate:
                return .none
            }
        }
        .ifLet(\.$addRecordNavigation, action: \.addRecordNavigation) {
            AddRecordNavigationStore()
        }
    }
}
