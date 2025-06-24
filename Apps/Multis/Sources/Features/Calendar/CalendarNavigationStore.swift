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

private func findTask(id: UUID, in tasksByDate: [Date: IdentifiedArrayOf<TaskModel>]) -> TaskModel? {
    for (_, tasks) in tasksByDate {
        if let task = tasks.first(where: { $0.id == id }) {
            return task
        }
    }
    return nil
}

@Reducer
public struct CalendarNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var tasksByDate: [Date: IdentifiedArrayOf<TaskModel>]
        public var selectedDate: Date
        
        // 멀티 타이머 관련 상태
        public var runningTimers: [UUID: TimerState] = [:]
        
        public var path: StackState<Path.State>
        public var addTaskPresentation: AddTaskPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            
            self.tasksByDate = [:]
            self.selectedDate = Calendar.current.startOfDay(for: .now)
            self.runningTimers = [:]
            self.addTaskPresentation = .init()
        }
    }
    
    public struct TimerState {
        public var taskId: UUID
        public var startTime: Date
        public var elapsedTime: Int
        
        public init(taskId: UUID) {
            self.taskId = taskId
            self.startTime = .now
            self.elapsedTime = 0
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
        case timerTick(UUID)
        
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
                state.runningTimers[task.id] = TimerState(taskId: task.id)
                return .run { send in
                    while true {
                        try await _Concurrency.Task.sleep(for: .seconds(1))
                        await send(.timerTick(task.id))
                    }
                }
                .cancellable(id: TimerID.timer(task.id))
                
            case .stopTimer(let taskId):
                guard let timerState = state.runningTimers[taskId] else { return .none }
                
                // 타이머 시간을 태스크에 업데이트 (초를 ms로 변환)
                if let task = findTask(id: taskId, in: state.tasksByDate) {
                    let elapsedMs = timerState.elapsedTime * 1000 // 초 → ms 변환
                    let updatedTask = TaskModel(
                        id: task.id,
                        title: task.title,
                        time: task.time + elapsedMs, // ms 단위로 누적
                        date: task.date,
                        task: task.task
                    )
                    
                    let totalHours = updatedTask.time / (60 * 60 * 1000)
                    let totalMinutes = (updatedTask.time % (60 * 60 * 1000)) / (60 * 1000)
                    let totalSeconds = (updatedTask.time % (60 * 1000)) / 1000
                    
                    print("🕐 Timer stopped for '\(task.title)': +\(timerState.elapsedTime)s → Total: \(totalHours)h \(totalMinutes)m \(totalSeconds)s")
                    
                    // TaskClient를 통해 업데이트
                    let savedTask = taskClient.createOrUpdate(taskModel: updatedTask)
                    
                    // State도 직접 업데이트
                    let taskDate = Calendar.current.startOfDay(for: task.date)
                    if var tasksForDate = state.tasksByDate[taskDate] {
                        if let index = tasksForDate.firstIndex(where: { $0.id == taskId }) {
                            tasksForDate[index] = savedTask
                            state.tasksByDate[taskDate] = tasksForDate
                        }
                    }
                }
                
                state.runningTimers.removeValue(forKey: taskId)
                return .concatenate(
                    .cancel(id: TimerID.timer(taskId)),
                    .send(.fetch) // 전체 데이터 새로고침으로 확실하게 동기화
                )
                
            case .timerTick(let taskId):
                if state.runningTimers[taskId] != nil {
                    state.runningTimers[taskId]?.elapsedTime += 1
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
