//
//  AddTagView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

struct AddTagView: View {
    @Bindable var store: StoreOf<AddTagStore>
    
    var body: some View {
        NavigationView {
            Form {
                // Name Section
                Section("Tag Name") {
                    TextField(
                        "Enter tag name",
                        text: $store.tag.name
                    )
                }
                
                // Color Section
                Section("Color") {
                    // Color Picker
                    HStack {
                        Text("Color")
                        Spacer()
                        ColorPicker("", selection: Binding(
                            get: { store.selectedColor },
                            set: { store.send(.colorChanged($0)) }
                        ))
                        .labelsHidden()
                    }
                    
                    // Color Preview
                    HStack {
                        Text("Preview")
                        Spacer()
                        Circle()
                            .fill(store.selectedColor)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Hex Code Input
                    HStack {
                        Text("Hex Code")
                        Spacer()
                        TextField(
                            "#FFFFFF",
                            text: $store.tag.hex
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .font(.system(.body, design: .monospaced))
                        .autocapitalization(.allCharacters)
                        .onChange(of: store.tag.hex) { _, newValue in
                            // Update color when hex changes
                            if let color = Color(hex: newValue) {
                                store.send(.colorChanged(color))
                            }
                        }
                    }
                }
                
                // Predefined Colors Section
                Section("Quick Colors") {
                    let predefinedColors: [(String, Color)] = [
                        ("Blue", .blue),
                        ("Red", .red),
                        ("Green", .green),
                        ("Orange", .orange),
                        ("Purple", .purple),
                        ("Pink", .pink),
                        ("Yellow", .yellow),
                        ("Teal", .teal)
                    ]
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(predefinedColors, id: \.0) { name, color in
                            Button {
                                store.send(.colorChanged(color))
                            } label: {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    store.selectedColor == color ? Color.primary : Color.gray.opacity(0.3),
                                                    lineWidth: store.selectedColor == color ? 2 : 1
                                                )
                                        )
                                    
                                    Text(name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Tag Preview Section
                if store.isFormValid {
                    Section("Preview") {
                        HStack {
                            // Tag Preview
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(store.selectedColor)
                                    .frame(width: 16, height: 16)
                                
                                Text(store.tag.name)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(store.selectedColor.opacity(0.1))
                            .foregroundColor(store.selectedColor)
                            .clipShape(Capsule())
                            
                            Spacer()
                        }
                        
                        // Tag Details
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Name:")
                                    .foregroundColor(.secondary)
                                Text(store.tag.name)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Color:")
                                    .foregroundColor(.secondary)
                                Text(store.tag.hex.uppercased())
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.medium)
                            }
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveButtonTapped)
                    }
                    .disabled(!store.isFormValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AddTagView(
        store: Store(initialState: AddTagStore.State()) {
            AddTagStore()
        }
    )
}
