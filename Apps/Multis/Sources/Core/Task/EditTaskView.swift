//
//  EditTaskView.swift
//  Multis
//
//  Created by 송영모 on 7/27/25.
//

import SwiftUI

public struct EditTaskView: View {
    @State private var task: TaskItem
    @State private var categories: [CategoryModel] = [] // TODO: 실제 카테고리 데이터 연결 필요
    
    private var saved: (TaskItem) -> Void
    private var dismiss: () -> Void
    private var isEditing: Bool
    
    public init(task: TaskItem?, saved: @escaping (TaskItem) -> Void, dismiss: @escaping () -> Void) {
        self.task = task ?? .init()
        self.saved = saved
        self.dismiss = dismiss
        self.isEditing = task != nil
    }
    
    public var body: some View {
        NavigationView {
            mainView
                .navigationTitle(isEditing ? "Edit Task" : "Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saved(task)
                        }
                        .disabled(!isTaskValid)
                    }
                }
        }
    }
}

extension EditTaskView {
    
    // MARK: - Validation Computed Properties
    
    private var validationError: String? {
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Title cannot be empty"
        }
        return nil
    }
    
    private var isTaskValid: Bool {
        return validationError == nil
    }
    
    // Title validation
    private var titleCheckmarkColor: Color {
        if task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .gray
        } else {
            return .green
        }
    }
    
    private var titleCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // Date validation - 항상 valid (기본값이 있음)
    private var dateCheckmarkColor: Color {
        return .green
    }
    
    private var dateCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        formContent
    }
    
    @ViewBuilder
    private var formContent: some View {
        Form {
            taskInformationSection
            
            if let errorMessage = validationError {
                validationErrorSection(errorMessage)
            }
            
            previewSection
        }
    }
    
    private var taskInformationSection: some View {
        Section(header: Text("Task Information")) {
            titleField
            dateSelector
            categorySelector
            timeDisplay
        }
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Image(systemName: titleCheckmarkImageName)
                    .foregroundColor(titleCheckmarkColor)
                    .font(.system(size: 12))
            }
            
            TextField(
                "Enter task title",
                text: $task.title
            )
        }
        .padding(.vertical, 4)
    }
    
    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Image(systemName: dateCheckmarkImageName)
                    .foregroundColor(dateCheckmarkColor)
                    .font(.system(size: 12))
            }
            
            DatePicker(
                "",
                selection: $task.date,
                displayedComponents: [.date]
            )
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
    
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 새 카테고리 추가 버튼
                    Button(action: {
                        // TODO: 카테고리 추가 기능 구현 필요
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                            Text("Add Category")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                    
                    // 기존 카테고리 선택
                    ForEach(categories) { category in
                        Button(action: {
                            task.category = category
                        }) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: category.color) ?? .blue)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.title)
                                    .font(.caption)
                            }
                            .foregroundColor(task.category?.id == category.id ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                task.category?.id == category.id ?
                                (Color(hex: category.color) ?? .blue) : Color.gray.opacity(0.2)
                            )
                            .cornerRadius(15)
                        }
                    }
                    
                    // 카테고리 없음 옵션
                    Button(action: {
                        task.category = nil
                    }) {
                        Text("No Category")
                            .font(.caption)
                            .foregroundColor(task.category == nil ? .white : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                task.category == nil ?
                                Color.gray : Color.gray.opacity(0.2)
                            )
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var timeDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatTaskTime(task.time))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if task.time > 0 {
                        Text("Time is currently recorded")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No time recorded")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if task.time > 0 {
                    Button("Reset") {
                        task.time = 0
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTaskTime(_ milliseconds: Int) -> String {
        let totalMs = milliseconds
        let hours = totalMs / (1000 * 60 * 60)
        let minutes = (totalMs % (1000 * 60 * 60)) / (1000 * 60)
        let seconds = (totalMs % (1000 * 60)) / 1000
        let ms = (totalMs % 1000) / 10 // 10ms 단위로 2자리 표시
        
        return String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, ms)
    }
    
    private func validationErrorSection(_ errorMessage: String) -> some View {
        Section {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Spacer()
            }
            .padding(.vertical, 4)
        } header: {
            Text("Validation Error")
        }
    }
    
    private var previewSection: some View {
        Section {
            TaskPreviewView(task: task)
        } header: {
            Text("Preview")
        }
    }
}

// MARK: - Task Preview View
private struct TaskPreviewView: View {
    let task: TaskItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title.isEmpty ? "Task Title" : task.title)
                        .font(.headline)
                        .foregroundColor(task.title.isEmpty ? .gray : .primary)
                    
                    Text(task.categoryDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let category = task.category {
                    Circle()
                        .fill(Color(hex: category.color) ?? .blue)
                        .frame(width: 20, height: 20)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Date")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(task.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if task.time > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Time")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(task.displayTime + "s")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
