//
//  EditGoalView.swift
//  Multis
//
//  Created by 송영모 on 7/27/25.
//

import SwiftUI

public struct EditGoalView: View {
    @State private var goal: GoalItem
    @State private var categories: [CategoryModel] = [] // TODO: 실제 카테고리 데이터 연결 필요
    
    private var saved: (GoalItem) -> Void
    private var dismiss: () -> Void
    private var isEditing: Bool
    
    public init(goal: GoalItem?, saved: @escaping (GoalItem) -> Void, dismiss: @escaping () -> Void) {
        self.goal = goal ?? .init()
        self.saved = saved
        self.dismiss = dismiss
        self.isEditing = goal != nil
    }
    
    public var body: some View {
        NavigationView {
            mainView
                .navigationTitle(isEditing ? "Edit Goal" : "Add Goal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saved(goal)
                        }
                        .disabled(!isGoalValid)
                    }
                }
        }
    }
}

extension EditGoalView {
    
    // MARK: - Validation Computed Properties
    
    private var validationError: String? {
        if goal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Title cannot be empty"
        }
        if let endDate = goal.endDate, endDate < goal.startDate {
            return "End date must be after start date"
        }
        return nil
    }
    
    private var isGoalValid: Bool {
        return validationError == nil
    }
    
    // Title validation
    private var titleCheckmarkColor: Color {
        if goal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
            goalInformationSection
            
            if let errorMessage = validationError {
                validationErrorSection(errorMessage)
            }
            
            previewSection
        }
    }
    
    private var goalInformationSection: some View {
        Section(header: Text("Goal Information")) {
            titleField
            startDateSelector
            endDateSelector
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
                "Enter goal title",
                text: $goal.title
            )
        }
        .padding(.vertical, 4)
    }
    
    private var startDateSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Start Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Image(systemName: dateCheckmarkImageName)
                    .foregroundColor(dateCheckmarkColor)
                    .font(.system(size: 12))
            }
            
            DatePicker(
                "",
                selection: $goal.startDate,
                displayedComponents: [.date]
            )
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
    
    private var endDateSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("End Date (Optional)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Toggle("Set end date", isOn: Binding(
                    get: { goal.endDate != nil },
                    set: { hasEndDate in
                        goal.endDate = hasEndDate ? Calendar.current.date(byAdding: .month, value: 1, to: goal.startDate) : nil
                    }
                ))
                .toggleStyle(SwitchToggleStyle())
            }
            
            if goal.endDate != nil {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { goal.endDate ?? Date() },
                        set: { goal.endDate = $0 }
                    ),
                    in: goal.startDate...,
                    displayedComponents: [.date]
                )
                .labelsHidden()
            }
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
                            goal.category = category
                        }) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: category.color) ?? .blue)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.title)
                                    .font(.caption)
                            }
                            .foregroundColor(goal.category?.id == category.id ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                goal.category?.id == category.id ?
                                (Color(hex: category.color) ?? .blue) : Color.gray.opacity(0.2)
                            )
                            .cornerRadius(15)
                        }
                    }
                    
                    // 카테고리 없음 옵션
                    Button(action: {
                        goal.category = nil
                    }) {
                        Text("No Category")
                            .font(.caption)
                            .foregroundColor(goal.category == nil ? .white : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                goal.category == nil ?
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
            Text("Total Time")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatGoalTime(goal.totalTime))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if goal.totalTime > 0 {
                        Text("Total time recorded")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No time recorded yet")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if goal.totalTime > 0 {
                    Button("Reset All") {
                        goal.times = [:]
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
    
    private func formatGoalTime(_ milliseconds: Int) -> String {
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
            GoalPreviewView(goal: goal)
        } header: {
            Text("Preview")
        }
    }
}

// MARK: - Goal Preview View
private struct GoalPreviewView: View {
    let goal: GoalItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title.isEmpty ? "Goal Title" : goal.title)
                        .font(.headline)
                        .foregroundColor(goal.title.isEmpty ? .gray : .primary)
                    
                    Text(goal.categoryDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let category = goal.category {
                    Circle()
                        .fill(Color(hex: category.color) ?? .blue)
                        .frame(width: 20, height: 20)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Date")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(goal.startDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if let endDate = goal.endDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("End Date")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(endDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            if goal.totalTime > 0 {
                HStack {
                    Text("Total Time:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(goal.displayTime + "s")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
