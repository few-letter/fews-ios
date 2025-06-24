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
                    Section(header: Text(key).font(.headline)) {
                        ForEach(store.groupedTasks[key] ?? [], id: \.id) { task in
                            TaskDocumentCellView(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    store.send(.tap(task))
                                }
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
        let formatter = DateFormatter()
        
        switch store.selectedPeriod {
        case .daily:
            formatter.dateFormat = "yyyy-MM-dd"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        
        return store.groupedTasks.keys.sorted { key1, key2 in
            let date1 = formatter.date(from: String(key1.prefix(10))) ?? Date.distantPast
            let date2 = formatter.date(from: String(key2.prefix(10))) ?? Date.distantPast
            return date1 > date2
        }
    }
}

// MARK: - TaskDocumentCellView
struct TaskDocumentCellView: View {
    let task: TaskModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title.isEmpty ? "Task Title" : task.title)
                    .font(.headline)
                    .foregroundColor(task.title.isEmpty ? .secondary : .primary)
                
                Spacer()
                
                if task.time > 0 {
                    Text("\(task.time) min")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Text(task.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
