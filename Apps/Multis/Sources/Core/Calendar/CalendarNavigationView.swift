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
    @Bindable public var store: StoreOf<CalendarNavigationStore>
    @State private var timerModel: any TimerModel
    
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
                timerModel: timerModel,
                onDateChanged: { date in
                    store.send(.dateChanged(date))
                },
                onDocumentTapped: { document in
                    switch document {
                    case .task(let taskData):
                        store.send(.tap(taskData))
                    case .goal(let goalData):
                        // Goal 탭 처리는 추후 구현
                        break
                    }
                },
                onPlusButtonTapped: {
                    store.send(.plusButtonTapped)
                },
                onDeleteDocument: { document in
                    switch document {
                    case .task(let taskData):
                        store.send(.delete(taskData))
                        timerModel.fetch()
                    case .goal(let goalData):
                        // Goal 삭제 처리는 추후 구현
                        break
                    }
                }
            )
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
