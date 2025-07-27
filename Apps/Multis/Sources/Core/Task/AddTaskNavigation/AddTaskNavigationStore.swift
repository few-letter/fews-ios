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
    public enum Path {
        case addCategory(AddCategoryStore)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>
        public var task: TaskItem
        public var categories: [CategoryModel] = []
        
        public init(
            path: StackState<Path.State> = .init(),
            task: TaskItem
        ) {
            self.path = path
            self.task = task
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case loadCategories
        
        case cancelButtonTapped
        case saveButtonTapped
        case addCategoryButtonTapped
        case resetTimeButtonTapped

        case path(StackActionOf<Path>)
        
        case delegate(Delegate)
        public enum Delegate {
            case dismiss
            case requestSaved
        }
    }
    
    @Dependency(\.taskClient) private var taskClient
    @Dependency(\.categoryClient) private var categoryClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .send(.loadCategories)
                
            case .loadCategories:
                state.categories = categoryClient.fetches()
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.dismiss))
                
            case .saveButtonTapped:
                let _ = taskClient.createOrUpdate(task: state.task)
                return .send(.delegate(.requestSaved))
                
            case .addCategoryButtonTapped:
                state.path.append(.addCategory(AddCategoryStore.State()))
                return .none
                
            case .resetTimeButtonTapped:
                state.task.time = 0
                return .none
                
            case .path(.element(_, action: .addCategory(.delegate(.categorySaved(let category))))):
                state.task.category = category
                state.path.removeLast()
                return .send(.loadCategories)
                
            case .path(.element(_, action: .addCategory(.delegate(.dismiss)))):
                state.path.removeLast()
                return .none
                
            case .binding, .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
