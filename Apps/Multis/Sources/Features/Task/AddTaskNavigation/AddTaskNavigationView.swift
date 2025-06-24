//
//  AddTaskNavigationView.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddTaskNavigationView: View {
    @Bindable public var store: StoreOf<AddTaskNavigationStore>
    
    public init(store: StoreOf<AddTaskNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .navigationTitle("Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            store.send(.cancelButtonTapped)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            store.send(.saveButtonTapped)
                        }
                        .disabled(!isTaskValid)
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension AddTaskNavigationView {
    
    // MARK: - Validation Computed Properties
    
    private var validationError: String? {
        if store.task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Title cannot be empty"
        }
        return nil
    }
    
    private var isTaskValid: Bool {
        return validationError == nil
    }
    
    // Title - 내용이 있는지 체크
    private var titleCheckmarkColor: Color {
        if store.task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .gray
        } else {
            return .green
        }
    }
    
    private var titleCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // Date - 항상 valid (기본값이 있음)
    private var dateCheckmarkColor: Color {
        return .green
    }
    
    private var dateCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // Time은 타이머로만 관리되므로 UI에서 제거
    
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
            // timeSelector 제거 - 타이머로만 관리
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
                text: .init(get: { store.task.title }, set: { store.send(.binding(.set(\.task.title, $0))) })
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
                selection: .init(get: { store.task.date }, set: { store.send(.binding(.set(\.task.date, $0))) }),
                displayedComponents: [.date]
            )
            .labelsHidden()
        }
        .padding(.vertical, 4)
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
            TaskCellView(task: store.task, isTimerRunning: false, onTimerToggle: {})
        } header: {
            Text("Preview")
        }
    }
}
