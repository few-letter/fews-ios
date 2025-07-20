//
//  AddCategoryStore.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AddCategoryStore {
    @ObservableState
    public struct State {
        public var category: CategoryModel
        
        public init(
            category: CategoryModel = CategoryModel()
        ) {
            self.category = category
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case cancelButtonTapped
        case saveButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case dismiss
            case categorySaved(CategoryModel)
        }
    }
    
    @Dependency(\.categoryClient) private var categoryClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.dismiss))
                
            case .saveButtonTapped:
                let savedCategory = categoryClient.createOrUpdate(categoryModel: state.category)
                return .send(.delegate(.categorySaved(savedCategory)))
                
            case .binding, .delegate:
                return .none
            }
        }
    }
} 