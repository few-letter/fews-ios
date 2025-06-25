//
//  DocumentNavigationStore.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import ComposableArchitecture

private enum TimerID: Hashable {
    case timer(UUID)
}

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
        
        // 실행 중인 타이머 ID들
        public var runningTimerIds: IdentifiedArrayOf<TaskTimerID> = []
        
        public var path: StackState<Path.State>
        public var addTaskPresentation: AddTaskPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            self.tasks = []
            self.selectedPeriod = .daily
            self.groupedTasks = [:]
            self.runningTimerIds = []
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
        
        // 타이머 관련 액션들
        case startTimer(TaskModel)
        case stopTimer(UUID)
        case timerTick(UUID, Int)
        
        // 백그라운드 타이머 관련
        case appWillEnterBackground
        case appWillEnterForeground
        case updateBackgroundTimers
        
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
                state.groupedTasks = groupTasksByCategory(tasks: filterTasksByPeriod(tasks: state.tasks, period: period))
                return .none
                
            case .tap(let task):
                state.addTaskPresentation.addTaskNavigation = .init(task: task)
                return .none
                
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
                
                if let taskIndex = state.tasks.firstIndex(where: { $0.id == taskId }) {
                    let task = state.tasks[taskIndex]
                    let savedTask = taskClient.createOrUpdate(taskModel: task)
                    state.tasks[taskIndex] = savedTask
                }
                
                return .concatenate(
                    .cancel(id: TimerID.timer(taskId)),
                    .send(.fetch)
                )
                
            case .timerTick(let taskId, let ms):
                guard state.runningTimerIds.contains(where: { $0.taskId == taskId }) else { 
                    return .none 
                }
                if let taskIndex = state.tasks.firstIndex(where: { $0.id == taskId }) {
                    state.tasks[taskIndex].time += ms
                    let task = state.tasks[taskIndex]
                    let _ = taskClient.createOrUpdate(taskModel: task)
                }
                return .none
                
            // 백그라운드 타이머 관련 액션들
            case .appWillEnterBackground:
                // 실행 중인 타이머들의 현재 시간을 기록
                for timerID in state.runningTimerIds {
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "timer_background_\(timerID.taskId)")
                }
                return .none
                
            case .appWillEnterForeground:
                return .send(.updateBackgroundTimers)
                
            case .updateBackgroundTimers:
                var totalElapsedTime: [UUID: Int] = [:]
                
                // 백그라운드에서 경과된 시간 계산
                for timerID in state.runningTimerIds {
                    let key = "timer_background_\(timerID.taskId)"
                    let backgroundStartTime = UserDefaults.standard.double(forKey: key)
                    
                    if backgroundStartTime > 0 {
                        let elapsedSeconds = Date().timeIntervalSince1970 - backgroundStartTime
                        let elapsedMilliseconds = Int(elapsedSeconds * 1000)
                        totalElapsedTime[timerID.taskId] = elapsedMilliseconds
                        
                        // 저장된 백그라운드 시간 삭제
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                }
                
                // 계산된 시간을 태스크에 반영
                for (taskId, elapsedTime) in totalElapsedTime {
                    if let taskIndex = state.tasks.firstIndex(where: { $0.id == taskId }) {
                        state.tasks[taskIndex].time += elapsedTime
                        let task = state.tasks[taskIndex]
                        let _ = taskClient.createOrUpdate(taskModel: task)
                    }
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
    
    private func groupTasksByCategory(tasks: [TaskModel]) -> [String: [TaskModel]] {
        return TaskModel.groupedByCategory(tasks)
    }
    
    private func filterTasksByPeriod(tasks: [TaskModel], period: DocumentPeriod) -> [TaskModel] {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredTasks = tasks.filter { task in
            switch period {
            case .daily:
                return calendar.isDate(task.date, inSameDayAs: now)
            case .monthly:
                return calendar.isDate(task.date, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(task.date, equalTo: now, toGranularity: .year)
            }
        }
        return filteredTasks
    }
}
