//
//  CalendarNavigationView.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture
import CommonFeature

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
                TaskRowView(
                    task: task,
                    isTimerRunning: store.runningTimers[task.id] != nil,
                    elapsedTime: store.runningTimers[task.id]?.elapsedTime ?? 0,
                    onTap: { store.send(.tap(task)) },
                    onTimerToggle: {
                        if store.runningTimers[task.id] != nil {
                            store.send(.stopTimer(task.id))
                        } else {
                            store.send(.startTimer(task))
                        }
                    }
                )
            }
            .onDelete { store.send(.delete($0)) }
        }
        .listStyle(.plain)
    }
    

}

// MARK: - TaskRowView (RecordCellView 스타일)
private struct TaskRowView: View {
    let task: TaskModel
    let isTimerRunning: Bool
    let elapsedTime: Int
    let onTap: () -> Void
    let onTimerToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 타이머 상태 아이콘과 색상
            Circle()
                .fill(isTimerRunning ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                )
                .onTapGesture {
                    onTimerToggle()
                }
            
            VStack(alignment: .leading, spacing: 6) {
                // Task title
                Text(task.title.isEmpty ? "Untitled Task" : task.title)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    // Accumulated total time
                    if task.time > 0 {
                        Text("Total \(formatTaskTime(task.time))")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.blue.opacity(0.12))
                            )
                    }
                    
                    Spacer()
                    
                    // Current running time (real-time update) - 오른쪽에 배치
                    if isTimerRunning {
                        Text("Running: \(formatElapsedTime(elapsedTime))")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.green.opacity(0.12))
                            )
                    }
                    
                    // Date display
                    Text(task.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatElapsedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, secs)
        } else {
            return "\(secs)s"
        }
    }
    
    private func formatTaskTime(_ milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else if seconds > 0 {
            return "\(seconds)s"
        } else {
            return "0s"
        }
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
        // 시간에 따라 색상 구분
        let time = task.time
        
        switch time {
        case 0..<30:
            return .green    // 30분 미만 - 초록
        case 30..<60:
            return .blue     // 30분~1시간 - 파랑
        case 60..<120:
            return .orange   // 1~2시간 - 주황
        default:
            return .red      // 2시간 이상 - 빨강
        }
    }
}
