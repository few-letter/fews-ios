//
//  CalendarNavigationView.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture
import Dependencies
import Feature_Common

public struct CalendarNavigationView: View {
    @Bindable var store: StoreOf<CalendarNavigationStore>
    @State var timerModel: any TimerModel
    
    @State private var showEditGoal: Presentation<GoalItem>?
    @State private var showEditTask: Presentation<TaskItem>?
    @State private var showSelectGoal: Presentation<[GoalItem]>?
    
    public init(store: StoreOf<CalendarNavigationStore>, timerModel: any TimerModel) {
        self.store = store
        self._timerModel = .init(wrappedValue: timerModel)
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            CalendarView(
                documentsByDate: timerModel.documentsByDate,
                onDateChanged: { date in
                    store.send(.dateChanged(date))
                },
                onDocumentTapped: { id in
                    guard let document =  self.timerModel.documents[id: id] else { return }
                    
                    switch document {
                    case .goal(let item):
                        self.showEditGoal = .init(value: item)
                    case .task(let item):
                        self.showEditTask = .init(value: item)
                    }
                },
                onGoalTapped: {
                    let goals: [GoalItem] = self.timerModel.documents.compactMap {
                        if case .goal(let item) = $0 {
                            return item
                        }
                        return nil
                    }
                    self.showSelectGoal = .init(value: goals)
                },
                onTaskTapped: {
                    self.showEditTask = .init(value: nil)
                },
                onDeleteDocument: { documentID in
                    timerModel.delete(documentID: documentID)
                },
                isTimerRunning: { documentID in
                    timerModel.isTimerRunning(documentID: documentID)
                },
                onTimerToggle: { documentID in
                    timerModel.toggle(documentID: documentID)
                }
            )
            .sheet(isPresented: .init(get: { self.showEditGoal != nil }, set: { _ in self.showEditGoal = nil })) {
                EditGoalView(
                    goal: self.showEditGoal?.value,
                    saved: { goal in
                        timerModel.update(document: .goal(goal))
                    },
                    dismiss: {
                        self.showEditGoal = nil
                    }
                )
            }
            .sheet(isPresented: .init(get: { self.showEditTask != nil }, set: { _ in self.showEditTask = nil })) {
                EditTaskView(
                    task: self.showEditTask?.value,
                    saved: { task in
                        timerModel.update(document: .task(task))
                    },
                    dismiss: {
                        self.showEditTask = nil
                    }
                )
            }
            .sheet(isPresented: .init(get: { self.showSelectGoal != nil }, set: { _ in self.showSelectGoal = nil })) {
                GoalsView(
                    goals: self.showSelectGoal?.value ?? [],
                    select: { _ in }
                )
            }
            .overlay {
                AddTaskPresentationView(store: store.scope(state: \.addTaskPresentation, action: \.addTaskPresentation))
            }
            .onAppear {
                store.send(.onAppear)
                timerModel.fetch()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                timerModel.handleAppWillEnterForeground()
                timerModel.fetch()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                timerModel.handleAppWillEnterBackground()
            }
        } destination: { store in
            
        }
    }
}

private struct Presentation<T> {
    let value: T?
}
