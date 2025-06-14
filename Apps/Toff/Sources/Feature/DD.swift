//
//  DD.swift
//  Toff
//
//  Created by 송영모 on 6/14/25.
//

import SwiftUI
import PhotosUI
import SwiftData

// TradeEditorView for creating or editing a Trade
struct TradeEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // The trade to edit; nil if creating a new trade
    var trade: Trade?
    
    // State variables for form fields
    @State private var side: TradeSide = .buy
    @State private var price: String = ""
    @State private var quantity: String = ""
    @State private var fee: String = ""
    @State private var images: [Data] = []
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var selectedTicker: Ticker?
    
    // State for ticker fetching and image picking
    @Query private var tickers: [Ticker]
    @State private var isShowingImagePicker = false
    @State private var imagePickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            Form {
                // Trade Details Section
                Section(header: Text("Trade Details")) {
                    Picker("Side", selection: $side) {
                        ForEach(TradeSide.allCases, id: \.self) { side in
                            Text(side.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.decimalPad)
                    
                    TextField("Fee", text: $fee)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date)
                }
                
                // Images Section
                Section(header: Text("Images")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(images.indices, id: \.self) { index in
                                if let uiImage = UIImage(data: images[index]) {
                                    HStack {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                        Button(action: {
                                            images.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Button("Add Image") {
                        isShowingImagePicker = true
                    }
                }
                
                // Note Section
                Section(header: Text("Note")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
                
                // Ticker Selection Section
                Section(header: Text("Ticker")) {
                    Picker("Ticker", selection: $selectedTicker) {
                        Text("None").tag(Ticker?.none)
                        ForEach(tickers, id: \.self) { ticker in
                            Text(ticker.name ?? "Unknown").tag(Ticker?.some(ticker))
                        }
                    }
                }
            }
            .navigationTitle(trade == nil ? "New Trade" : "Edit Trade")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTrade()
                    }
                }
            }
            .onAppear {
                if let trade = trade {
                    side = trade.side
                    price = String(format: "%.2f", trade.price)
                    quantity = String(format: "%.2f", trade.quantity)
                    fee = String(format: "%.2f", trade.fee)
                    images = trade.images
                    note = trade.note
                    date = trade.date
                    selectedTicker = trade.ticker
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                PhotosPicker(selection: $imagePickerItems, matching: .images) {
                    Text("Select Images")
                }
            }
            .onChange(of: imagePickerItems) { newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            images.append(data)
                        }
                    }
                }
            }
        }
    }
    
    // Save or update the trade
    private func saveTrade() {
        let tradeToSave: Trade
        if let existingTrade = trade {
            tradeToSave = existingTrade
        } else {
            tradeToSave = Trade(
                side: side,
                price: Double(price) ?? 0,
                quantity: Double(quantity) ?? 0,
                fee: Double(fee) ?? 0,
                images: images,
                note: note,
                date: date,
                ticker: selectedTicker
            )
            modelContext.insert(tradeToSave)
        }
        
        // Update properties
        tradeToSave.side = side
        tradeToSave.price = Double(price) ?? 0
        tradeToSave.quantity = Double(quantity) ?? 0
        tradeToSave.fee = Double(fee) ?? 0
        tradeToSave.images = images
        tradeToSave.note = note
        tradeToSave.date = date
        tradeToSave.ticker = selectedTicker
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving trade: \(error)")
        }
    }
}

// Preview
#Preview {
    TradeEditorView()
}
