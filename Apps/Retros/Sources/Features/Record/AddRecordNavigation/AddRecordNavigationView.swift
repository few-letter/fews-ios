//
//  AddRecordNavigationView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddRecordNavigationView: View {
    @Bindable public var store: StoreOf<AddRecordNavigationStore>
    
    public init(store: StoreOf<AddRecordNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .navigationTitle("Add Record")
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
                        .disabled(!isRecordValid)
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension AddRecordNavigationView {
    
    // MARK: - Validation Computed Properties
    
    private var validationError: String? {
        if store.record.context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Context cannot be empty"
        }
        return nil
    }
    
    private var isRecordValid: Bool {
        return validationError == nil
    }
    
    // Type - 항상 valid (기본값이 있음)
    private var typeCheckmarkColor: Color {
        return .green
    }
    
    private var typeCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // Context - 내용이 있는지 체크
    private var contextCheckmarkColor: Color {
        if store.record.context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .gray
        } else {
            return .green
        }
    }
    
    private var contextCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // Date - 항상 valid (기본값이 있음)
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
            recordInformationSection
            
            if let errorMessage = validationError {
                validationErrorSection(errorMessage)
            }
            
            previewSection
        }
    }
    
    private var recordInformationSection: some View {
        Section(header: Text("Record Information")) {
            typeSelector
            dateSelector
            contextField
        }
    }
    
    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Image(systemName: typeCheckmarkImageName)
                    .foregroundColor(typeCheckmarkColor)
                    .font(.system(size: 12))
            }
            
            Button {
                // 다음 타입으로 순환
                let currentType = RecordType(rawValue: store.record.type.rawValue) ?? .keep
                let allCases = RecordType.allCases
                let currentIndex = allCases.firstIndex(of: currentType) ?? 0
                let nextIndex = (currentIndex + 1) % allCases.count
                let nextType = allCases[nextIndex]
                
                store.send(.binding(.set(\.record.type, nextType)))
            } label: {
                HStack {
                    Image(systemName: RecordType(rawValue: store.record.type.rawValue)?.systemImageName ?? "circle")
                        .foregroundColor(RecordType(rawValue: store.record.type.rawValue)?.color ?? .gray)
                    Text(RecordType(rawValue: store.record.type.rawValue)?.displayName ?? "Unknown")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
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
                selection: .init(get: { store.record.showAt }, set: { store.send(.binding(.set(\.record.showAt, $0))) }),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
    
    private var contextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Context")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Image(systemName: contextCheckmarkImageName)
                    .foregroundColor(contextCheckmarkColor)
                    .font(.system(size: 12))
            }
            
            TextField(
                "Enter record context",
                text: .init(get: { store.record.context }, set: { store.send(.binding(.set(\.record.context, $0))) }),
                axis: .vertical
            )
            .lineLimit(3...6)
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
            RecordCellView(record: store.record)
        } header: {
            Text("Preview")
        }
    }
}
