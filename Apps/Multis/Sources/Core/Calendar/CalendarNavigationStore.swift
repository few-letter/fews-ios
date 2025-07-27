//
//  CalendarNavigationStore.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CalendarNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var selectedDate: Date
        
        public var path: StackState<Path.State>
        public var addTaskPresentation: AddTaskPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            self.selectedDate = Calendar.current.startOfDay(for: .now)
            self.addTaskPresentation = .init()
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case dateChanged(Date)
        case plusButtonTapped
        case tap(TaskItem)
        case delete(TaskItem)
        
        case addTaskPresentation(AddTaskPresentationStore.Action)
        case path(StackActionOf<Path>)
    }
    
    @Dependency(\.taskClient) private var taskClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .dateChanged(let date):
                state.selectedDate = date
                return .none
                
            case .plusButtonTapped:
                state.addTaskPresentation.addTaskNavigation = .init(task: .init(date: state.selectedDate))
                return .none
                
            case .tap(let task):
                state.addTaskPresentation.addTaskNavigation = .init(task: task)
                return .none
                
            case .delete(let task):
                taskClient.delete(task: task)
                return .none
                
            case .addTaskPresentation(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .none
                }
                
            case .binding, .path, .addTaskPresentation:
                return .none
            }
        }
        
        Scope(state: \.addTaskPresentation, action: \.addTaskPresentation) {
            AddTaskPresentationStore()
        }
        .forEach(\.path, action: \.path)
    }
}
