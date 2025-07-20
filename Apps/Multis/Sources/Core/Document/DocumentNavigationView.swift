//
//  DocumentNavigationView.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture

public struct DocumentNavigationView: View {
    @Bindable public var store: StoreOf<DocumentNavigationStore>
    
    public init(store: StoreOf<DocumentNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            contentView
                .navigationTitle("Documents")
                .refreshable {
                    store.send(.onAppear)
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .overlay {
                    AddTaskPresentationView(store: store.scope(state: \.addTaskPresentation, action: \.addTaskPresentation))
                }
        } destination: { store in
            
        }
    }
}

extension DocumentNavigationView {
    private var contentView: some View {
        VStack(spacing: 0) {
            controlsView
                .padding()
            
            tasksListView
        }
    }
    
    private var controlsView: some View {
        HStack {
            Text("Period")
                .font(.headline)
            Spacer()
            Picker("Period", selection: .init(
                get: { store.selectedPeriod },
                set: { store.send(.periodChanged($0)) }
            )) {
                ForEach(DocumentPeriod.allCases, id: \.self) { period in
                    Text(period.displayText).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var tasksListView: some View {
        List {
            if store.groupedTasks.isEmpty {
                emptyStateView
            } else {
                ForEach(sortedGroupKeys, id: \.self) { key in
                    Section(header: sectionHeaderView(for: key)) {
                        ForEach(store.groupedTasks[key] ?? [], id: \.id) { task in
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
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Tasks")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("Start creating your tasks to see them here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
    
    private var sortedGroupKeys: [String] {
        return store.groupedTasks.keys.sorted { key1, key2 in
            if key1 == "No Category" { return false }
            if key2 == "No Category" { return true }
            return key1 < key2
        }
    }
    
    private func sectionHeaderView(for key: String) -> some View {
        let tasks = store.groupedTasks[key] ?? []
        let totalTime = tasks.reduce(0) { $0 + $1.time } // milliseconds
        
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(key)
                    .font(.headline)
                Text("\(tasks.count) tasks • \(formattedTime(totalTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formattedTime(_ milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
