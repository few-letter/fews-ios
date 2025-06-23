//
//  AddRecordNavigationStore.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddRecordNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        public var record: RecordModel
        
        public init(
            path: StackState<Path.State> = .init(),
        ) {
            self.path = path
            self.record = .init(id: .init(), type: .keep, context: "", showAt: .now, updateAt: .now)
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case cancelButtonTapped
        case saveButtonTapped

        case path(StackActionOf<Path>)
        
        case delegate(Delegate)
        public enum Delegate {
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .cancelButtonTapped:
                return .none
                
            case .saveButtonTapped:
                return .none
                
            case .binding, .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
