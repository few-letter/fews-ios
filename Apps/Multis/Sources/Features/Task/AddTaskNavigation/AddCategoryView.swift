//
//  AddCategoryView.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddCategoryView: View {
    @Bindable public var store: StoreOf<AddCategoryStore>
    
    public init(store: StoreOf<AddCategoryStore>) {
        self.store = store
    }
    
    private let predefinedColors = [
        "#FF6B6B", // Red
        "#4ECDC4", // Teal
        "#45B7D1", // Blue
        "#96CEB4", // Green
        "#FECA57", // Yellow
        "#FF9FF3", // Pink
        "#54A0FF", // Light Blue
        "#5F27CD", // Purple
        "#00D2D3", // Cyan
        "#FF9F43"  // Orange
    ]
    
    public var body: some View {
        NavigationView {
            Form {
                categoryInformationSection
                colorSelectionSection
                previewSection
            }
            .navigationTitle("새 카테고리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        store.send(.cancelButtonTapped)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        store.send(.saveButtonTapped)
                    }
                    .disabled(!isCategoryValid)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension AddCategoryView {
    private var isCategoryValid: Bool {
        return !store.category.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var categoryInformationSection: some View {
        Section(header: Text("카테고리 정보")) {
            HStack {
                Text("이름")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField(
                    "카테고리 이름을 입력하세요",
                    text: .init(get: { store.category.title }, set: { store.send(.binding(.set(\.category.title, $0))) })
                )
            }
            .padding(.vertical, 4)
        }
    }
    
    private var colorSelectionSection: some View {
        Section(header: Text("색상 선택")) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(predefinedColors, id: \.self) { colorHex in
                    Button(action: {
                        store.send(.binding(.set(\.category.color, colorHex)))
                    }) {
                        Circle()
                            .fill(Color(hex: colorHex) ?? .blue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(
                                        store.category.color == colorHex ? Color.primary : Color.clear,
                                        lineWidth: 3
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var previewSection: some View {
        Section(header: Text("미리보기")) {
            HStack {
                Circle()
                    .fill(Color(hex: store.category.color) ?? .blue)
                    .frame(width: 20, height: 20)
                
                Text(store.category.title.isEmpty ? "카테고리 이름" : store.category.title)
                    .font(.subheadline)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

