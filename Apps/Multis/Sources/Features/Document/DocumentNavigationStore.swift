//
//  DocumentNavigationStore.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import ComposableArchitecture

public enum DocumentPeriod: String, CaseIterable {
    case daily = "daily"
    case monthly = "monthly"
    case yearly = "yearly"
    
    public var displayText: String {
        switch self {
        case .daily:
            return "Daily"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

@Reducer
public struct DocumentNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var tasks: [TaskModel]
        public var selectedPeriod: DocumentPeriod
        public var groupedTasks: [String: [TaskModel]]
        
        public var path: StackState<Path.State>
        public var addTaskPresentation: AddTaskPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            self.tasks = []
            self.selectedPeriod = .daily
            self.groupedTasks = [:]
            self.addTaskPresentation = .init()
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetch
        case fetched([TaskModel])
        case periodChanged(DocumentPeriod)
        
        case tap(TaskModel)
        
        case addTaskPresentation(AddTaskPresentationStore.Action)
        case path(StackActionOf<Path>)
    }
    
    @Dependency(\.taskClient) private var taskClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .send(.fetch)
                
            case .fetch:
                let tasks = taskClient.fetches()
                return .send(.fetched(tasks))
                
            case .fetched(let tasks):
                state.tasks = tasks.sorted { lhs, rhs in
                    if lhs.time != rhs.time {
                        return lhs.time > rhs.time
                    }
                    return lhs.date > rhs.date
                }
                return .send(.periodChanged(state.selectedPeriod))
                
            case .periodChanged(let period):
                state.selectedPeriod = period
                state.groupedTasks = groupTasksByPeriod(tasks: state.tasks, period: period)
                return .none
                
            case .tap(let task):
                state.addTaskPresentation.addTaskNavigation = .init(task: task)
                return .none
                
            case .addTaskPresentation(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .send(.fetch)
                }
                return .none
                
            case .binding, .path, .addTaskPresentation:
                return .none
            }
        }
        
        Scope(state: \.addTaskPresentation, action: \.addTaskPresentation) {
            AddTaskPresentationStore()
        }
        .forEach(\.path, action: \.path)
    }
    
    private func groupTasksByPeriod(tasks: [TaskModel], period: DocumentPeriod) -> [String: [TaskModel]] {
        let formatter = DateFormatter()
        
        switch period {
        case .daily:
            formatter.dateFormat = "yyyy-MM-dd (EEEE)"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        
        let grouped = Dictionary(grouping: tasks) { task in
            formatter.string(from: task.date)
        }
        
        return grouped.mapValues { tasks in
            tasks.sorted { lhs, rhs in
                if lhs.time != rhs.time {
                    return lhs.time > rhs.time
                }
                return lhs.date > rhs.date
            }
        }
    }
}
