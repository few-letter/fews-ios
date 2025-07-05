//
//  CalendarNavigationView.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture
import Feature_Common

public struct CalendarNavigationView: View {
    @Bindable public var store: StoreOf<CalendarNavigationStore>
    
    public init(store: StoreOf<CalendarNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension CalendarNavigationView {
    private var mainView: some View {
        calendarView
            .overlay {
                AddTaskPresentationView(store: store.scope(state: \.addTaskPresentation, action: \.addTaskPresentation))
            }
    }
    
    private var calendarView: some View {
        CollapsibleCalendarView(
            itemProvider: { date in
                return store.tasksByDate[date]?.elements ?? []
            },
            onDateChanged: { date in
                store.send(.dateChanged(date))
            },
            cellContent: { date, items, isSelected, isToday, isInCurrentMonth, height in
                CalendarCellContent(
                    date: date,
                    tasks: items,
                    isSelected: isSelected,
                    isToday: isToday,
                    isInCurrentMonth: isInCurrentMonth,
                    height: height
                )
            },
            handleContent: {
                calendarHandleView
            },
            eventListContent: { tasks in
                calendarEventListView(tasks: tasks)
            })
    }
    
    private var calendarHandleView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 44, height: 4)
            
            HStack {
                Spacer()
                Button(action: {
                    store.send(.plusButtonTapped)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func calendarEventListView(tasks: [TaskModel]) -> some View {
        List {
            ForEach(tasks) { task in
                Button(action: {
                    store.send(.tap(task))
                }) {
                    TaskCellView(
                        task: task,
                        isTimerRunning: store.runningTimerIds.contains(where: { $0.taskId == task.id }),
                        onTimerToggle: {
                            if store.runningTimerIds.contains(where: { $0.taskId == task.id }) {
                                store.send(.stopTimer(task.id))
                            } else {
                                store.send(.startTimer(task))
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
            .onDelete { store.send(.delete($0)) }
        }
        .listStyle(.plain)
    }
    

}

private struct CalendarCellContent: View {
    let date: Date
    let tasks: [TaskModel]
    let isSelected: Bool
    let isToday: Bool
    let isInCurrentMonth: Bool
    let height: CGFloat
    
    private let calendar = Calendar.current
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    var body: some View {
        VStack(spacing: 1) {
            dayNumberView
                .frame(height: 20)
            
            if height > 40 {
                fullTaskList
            } else {
                compactTaskIndicator
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: height, alignment: .top)
    }
    
    private var dayNumberView: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20)
            }
            
            Text("\(dayNumber)")
                .font(.system(size: height > 40 ? 11 : 13, weight: .medium))
                .foregroundStyle(dayNumberTextColor)
        }
    }
    
    private var compactTaskIndicator: some View {
        Group {
            if !tasks.isEmpty {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 3, height: 3)
            }
        }
    }
    
    private var fullTaskList: some View {
        VStack(spacing: 0.5) {
            ForEach(Array(tasks.prefix(3).enumerated()), id: \.offset) { index, task in
                HStack(spacing: 2) {
                    Circle()
                        .fill(taskTypeColor(for: task))
                        .frame(width: 4, height: 4)
                    
                    Text(taskDisplayText(for: task))
                        .font(.system(size: 7))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if tasks.count > 3 {
                Text("•••")
                    .font(.system(size: 7))
                    .foregroundColor(.accentColor)
                    .padding(.top, 1)
            }
        }
    }
    
    private var dayNumberTextColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return isInCurrentMonth ? .primary : .secondary.opacity(0.5)
    }
    
    private func taskDisplayText(for task: TaskModel) -> String {
        let title = task.title
        return String(title.prefix(8))
    }
    
    private func taskTypeColor(for task: TaskModel) -> Color {
        // 카테고리 색상 우선 사용
        if let category = task.category {
            return Color(hex: category.color) ?? .accentColor
        }
        
        // 카테고리가 없는 경우 기본 색상
        return .gray
    }
}
