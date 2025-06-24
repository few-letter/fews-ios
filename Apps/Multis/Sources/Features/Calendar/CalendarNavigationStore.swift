//
//  CalendarNavigationStore.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import ComposableArchitecture

private enum TimerID: Hashable {
    case timer(UUID)
}

@Reducer
public struct CalendarNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var tasksByDate: [Date: IdentifiedArrayOf<TaskModel>]
        public var selectedDate: Date
        
        // 실행 중인 타이머 ID들
        public var runningTimerIds: IdentifiedArrayOf<TaskTimerID> = []
        
        public var path: StackState<Path.State>
        public var addTaskPresentation: AddTaskPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            
            self.tasksByDate = [:]
            self.selectedDate = Calendar.current.startOfDay(for: .now)
            self.runningTimerIds = []
            self.addTaskPresentation = .init()
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetch
        case fetched([TaskModel])
        
        case dateChanged(Date)
        case plusButtonTapped
        case tap(TaskModel)
        case delete(IndexSet)
        
        // 타이머 관련 액션들
        case startTimer(TaskModel)
        case stopTimer(UUID)
        case timerTick(UUID, Int)
        
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
                state.tasksByDate = [:]
                
                let groupedByDate = Dictionary(grouping: tasks) { task in
                    Calendar.current.startOfDay(for: task.date)
                }
                
                for (date, tasksForDate) in groupedByDate {
                    let sortedTasks = tasksForDate.sorted()
                    state.tasksByDate[date] = IdentifiedArrayOf(uniqueElements: sortedTasks)
                }
                
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
                
            case .delete(let indexSet):
                let selectedTasks = Array(state.tasksByDate[state.selectedDate]?.elements ?? [])
                for index in indexSet {
                    if index < selectedTasks.count {
                        let taskToDelete = selectedTasks[index]
                        taskClient.delete(taskModel: taskToDelete)
                        state.tasksByDate[state.selectedDate]?.remove(id: taskToDelete.id)
                    }
                }
                return .send(.fetch)
                
            // 타이머 관련 액션 처리
            case .startTimer(let task):
                let timerID = TaskTimerID(taskId: task.id, date: task.date)
                state.runningTimerIds.append(timerID)
                return .run { send in
                    while true {
                        try await _Concurrency.Task.sleep(for: .milliseconds(100))
                        await send(.timerTick(task.id, 100))
                    }
                }
                .cancellable(id: TimerID.timer(task.id))
                
            case .stopTimer(let taskId):
                state.runningTimerIds.removeAll { $0.taskId == taskId }
                
                if let timerID = state.runningTimerIds.first(where: { $0.taskId == taskId }),
                   let tasksForDate = state.tasksByDate[timerID.date],
                   let task = tasksForDate[id: taskId] {
                    
                    let savedTask = taskClient.createOrUpdate(taskModel: task)
                    state.tasksByDate[timerID.date]?[id: taskId] = savedTask
                }
                
                return .concatenate(
                    .cancel(id: TimerID.timer(taskId)),
                    .send(.fetch)
                )
                
            case .timerTick(let taskId, let ms):
                guard let timerID = state.runningTimerIds.first(where: { $0.taskId == taskId }) else { 
                    return .none 
                }
                state.tasksByDate[timerID.date]?[id: taskId]?.time += ms
                if let task = state.tasksByDate[timerID.date]?[id: taskId] {
                    let _ = taskClient.createOrUpdate(taskModel: task)
                }
                return .none
                
            case .addTaskPresentation(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .send(.fetch)
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
