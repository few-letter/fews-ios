//
//  AddTradeView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct AddTradeView: View {
    @Bindable var store: StoreOf<AddTradeStore>
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            Form {
                // Trade Side Section
                Section("Trade Type") {
                    Picker("Side", selection: $store.trade.side) {
                        Text("Buy").tag(TradeSide.buy)
                        Text("Sell").tag(TradeSide.sell)
                    }
                    .pickerStyle(.segmented)
                }
                
                // Ticker Selection
                Section("Ticker") {
                    Picker("Select Ticker", selection: $store.trade.ticker) {
                        Text("Select a ticker").tag(nil as Ticker?)
                        ForEach(store.availableTickers, id: \.id) { ticker in
                            Text(ticker.symbol).tag(ticker as Ticker?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Price and Quantity Section
                Section("Trade Details") {
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField(
                            "0.00",
                            text: $store.priceText
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField(
                            "0",
                            text: $store.quantityText
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fee")
                        Spacer()
                        TextField(
                            "0.00",
                            text: $store.feeText
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                // Date Section
                Section("Date") {
                    DatePicker(
                        "Trade Date",
                        selection: $store.trade.date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // Note Section
                Section("Note") {
                    TextField(
                        "Add a note (optional)",
                        text: $store.trade.note,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
                
                // Images Section
                Section("Images") {
                    if !store.trade.images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(store.trade.images.enumerated()), id: \.offset) { index, imageData in
                                    if let image = UIImage(data: imageData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                Button {
                                                    store.send(.imageRemoved(IndexSet(integer: index)))
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.black.opacity(0.6))
                                                        .clipShape(Circle())
                                                }
                                                .frame(width: 20, height: 20),
                                                alignment: .topTrailing
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "photo.badge.plus")
                    }
                    .onChange(of: selectedPhotos) { _, newItems in
                        Task {
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    await MainActor.run {
                                        store.send(.imageAdded(data))
                                    }
                                }
                            }
                            selectedPhotos.removeAll()
                        }
                    }
                }
                
                // Summary Section
                if store.isFormValid {
                    Section("Summary") {
                        HStack {
                            Text("Total Value")
                            Spacer()
                            Text("$\(String(format: "%.2f", store.trade.price * store.trade.quantity))")
                                .fontWeight(.semibold)
                        }
                        
                        if store.trade.fee > 0 {
                            HStack {
                                Text("Fee")
                                Spacer()
                                Text("$\(String(format: "%.2f", store.trade.fee))")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Trade")
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

#Preview {
    AddTradeView(
        store: Store(initialState: AddTradeStore.State()) {
            AddTradeStore()
        }
    )
}
