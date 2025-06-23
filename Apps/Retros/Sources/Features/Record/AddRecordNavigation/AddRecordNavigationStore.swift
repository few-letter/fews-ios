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
            case dismiss
            case requestSaved
        }
    }
    
    @Dependency(\.recordClient) private var recordClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.dismiss))
                
            case .saveButtonTapped:
                let _ = recordClient.createOrUpdate(recordModel: state.record)
                return .send(.delegate(.requestSaved))
                
            case .binding, .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
