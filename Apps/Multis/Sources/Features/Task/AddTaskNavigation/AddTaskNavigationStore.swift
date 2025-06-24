//
//  AddTaskNavigationStore.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddTaskNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        public var task: TaskModel
        
        public init(
            path: StackState<Path.State> = .init(),
            task: TaskModel
        ) {
            self.path = path
            self.task = task
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
    
    @Dependency(\.taskClient) private var taskClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.dismiss))
                
            case .saveButtonTapped:
                let _ = taskClient.createOrUpdate(taskModel: state.task)
                return .send(.delegate(.requestSaved))
                
            case .binding, .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
