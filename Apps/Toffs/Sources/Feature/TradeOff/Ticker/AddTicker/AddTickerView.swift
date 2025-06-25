//
//  AddTickerView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddTickerView: View {
    @Bindable var store: StoreOf<AddTickerStore>
    
    public var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ticker Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("e.g., AAPL, Samsung", text: $store.ticker.name)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Type", selection: $store.ticker.type) {
                        ForEach(TickerType.allCases, id: \.self) { type in
                            HStack(spacing: 8) {
                                Image(systemName: type.systemImageName)
                                    .foregroundColor(.black)
                                Text(type.displayText)
                                    .foregroundColor(.black)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.black)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Currency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Currency", selection: $store.ticker.currency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            HStack(spacing: 8) {
                                Image(systemName: currency.systemImageName)
                                    .foregroundColor(.black)
                                Text(currency.displayText)
                                    .foregroundColor(.black)
                            }
                            .tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.black)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                TickerCellView(ticker: store.ticker)
            } header: {
                Text("Preview")
            }
            
            if !store.tags.isEmpty {
                Section(header: Text("Tags")) {
                    ForEach(store.tags) { tag in
                        Text(tag.name)
                    }
                }
            }
        }
        .navigationTitle("Add New Ticker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    store.send(.saveButtonTapped)
                }
                .disabled(store.ticker.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
