//
//  CreateFolderStore.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddFolderStore {
    @ObservableState
    public struct State: Equatable {
        public var parentFolder: Folder?
        public var name: String
        
        public init(parentFolder: Folder?, name: String) {
            self.parentFolder = parentFolder
            self.name = name
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        
        case confirm
        case cancel
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case confirm(Folder?, String)
            case dismiss
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .confirm:
                return .send(.delegate(.confirm(state.parentFolder, state.name)))
                
            case .cancel:
                return .send(.delegate(.dismiss))
                
            case .delegate, .binding:
                return .none
            }
        }
    }
}
