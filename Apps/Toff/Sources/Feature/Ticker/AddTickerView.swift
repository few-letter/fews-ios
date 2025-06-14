//
//  AddTickerView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

struct AddTickerView: View {
    @Bindable var store: StoreOf<AddTickerStore>
    
    var body: some View {
        NavigationView {
            Form {
                // Ticker Type Section
                Section("Type") {
                    Picker("Ticker Type", selection: $store.ticker.type) {
                        ForEach(TickerType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Currency Section
                Section("Currency") {
                    Picker("Currency", selection: $store.ticker.currency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            HStack {
                                Text(currency.symbol)
                                Text(currency.displayName)
                            }
                            .tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Name Section
                Section("Details") {
                    HStack {
                        Text("Name")
                        TextField(
                            "Enter ticker name",
                            text: $store.ticker.name
                        )
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                // Tags Section
                if !store.availableTags.isEmpty {
                    Section("Tags") {
                        ForEach(store.availableTags, id: \.id) { tag in
                            HStack {
                                Button {
                                    store.send(.tagToggled(tag))
                                } label: {
                                    HStack {
                                        Image(systemName: store.selectedTags.contains(tag) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(store.selectedTags.contains(tag) ? .blue : .gray)
                                        
                                        Text(tag.name)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if store.selectedTags.isEmpty {
                            Text("No tags selected")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(store.selectedTags), id: \.id) { tag in
                                        Text(tag.name)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                
                // Summary Section
                if store.isFormValid {
                    Section("Summary") {
                        HStack {
                            Text("Type")
                            Spacer()
                            Text(store.ticker.type.displayName)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Currency")
                            Spacer()
                            HStack(spacing: 4) {
                                Text(store.ticker.currency.symbol)
                                Text(store.ticker.currency.displayName)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(store.ticker.name)
                                .fontWeight(.semibold)
                        }
                        
                        if !store.selectedTags.isEmpty {
                            HStack {
                                Text("Tags")
                                Spacer()
                                Text("\(store.selectedTags.count) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Ticker")
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
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Extensions for Display Names
extension TickerType {
    var displayName: String {
        switch self {
        case .stock:
            return "Stock"
        case .crypto:
            return "Crypto"
        case .forex:
            return "Forex"
        case .commodity:
            return "Commodity"
        // Add other cases as needed
        }
    }
}

extension Currency {
    var displayName: String {
        switch self {
        case .dollar:
            return "US Dollar"
        case .euro:
            return "Euro"
        case .yen:
            return "Japanese Yen"
        case .won:
            return "Korean Won"
        // Add other cases as needed
        }
    }
    
    var symbol: String {
        switch self {
        case .dollar:
            return "$"
        case .euro:
            return "€"
        case .yen:
            return "¥"
        case .won:
            return "₩"
        // Add other cases as needed
        }
    }
}

#Preview {
    AddTickerView(
        store: Store(initialState: AddTickerStore.State()) {
            AddTickerStore()
        }
    )
}
