//
//  TradeNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import SwiftUI
import ComposableArchitecture

public struct TradeNavigationView: View {
    @Bindable var store: StoreOf<TradeNavigationStore>
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .navigationTitle(store.ticker.name)
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
                        .disabled(!store.isFormValid || !isTradeValid)
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension TradeNavigationView {
    
    // MARK: - Validation Computed Properties
    
    private var validationError: String? {
        return store.temporaryTrade.validateBalance(in: store.trades)
    }
    
    private var isTradeValid: Bool {
        return validationError == nil
    }
    
    // Price - 단순히 값이 있는지만 체크
    private var priceCheckmarkColor: Color {
        if store.temporaryTrade.price == 0 {
            return .gray
        } else {
            return .green
        }
    }
    
    private var priceCheckmarkImageName: String {
        return "checkmark.circle.fill"
    }
    
    // Quantity - validation error까지 체크
    private var quantityCheckmarkColor: Color {
        if store.temporaryTrade.quantity == 0 {
            return .gray
        } else if store.temporaryTrade.quantity > 0 && isTradeValid {
            return .green
        } else {
            return .red
        }
    }
    
    private var quantityCheckmarkImageName: String {
        if store.temporaryTrade.quantity == 0 {
            return "checkmark.circle.fill"
        } else if store.temporaryTrade.quantity > 0 && isTradeValid {
            return "checkmark.circle.fill"
        } else {
            return "xmark.circle.fill"
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        Form {
            Section(header: Text("Trade Information")) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Side")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                        }
                        
                        Menu {
                            ForEach(TradeSide.allCases, id: \.self) { side in
                                Button {
                                    store.send(.binding(.set(\.temporaryTrade.side, side)))
                                } label: {
                                    HStack {
                                        Image(systemName: side.systemImageName)
                                        Text(side.displayText)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: store.temporaryTrade.side.systemImageName)
                                    .foregroundColor(.black)
                                Text(store.temporaryTrade.side.displayText)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                        }
                        
                        DatePicker(
                            "",
                            selection: .init(get: { store.temporaryTrade.date }, set: { store.send(.binding(.set(\.temporaryTrade.date, $0))) }),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Price")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: priceCheckmarkImageName)
                                    .foregroundColor(priceCheckmarkColor)
                                    .font(.system(size: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Quantity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: quantityCheckmarkImageName)
                                    .foregroundColor(quantityCheckmarkColor)
                                    .font(.system(size: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            TextField("Decimal allowed", value: Binding<Double?>(
                                get: { store.temporaryTrade.price == 0 ? nil : store.temporaryTrade.price },
                                set: { store.temporaryTrade.price = $0 ?? 0 }
                            ), format: .number)
                            .keyboardType(.decimalPad)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading) {
                            TextField("Decimal allowed", value: Binding<Double?>(
                                get: { store.temporaryTrade.quantity == 0 ? nil : store.temporaryTrade.quantity },
                                set: { store.temporaryTrade.quantity = $0 ?? 0 }
                            ), format: .number)
                            .keyboardType(.decimalPad)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fee")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Percentage", value: Binding<Double?>(
                        get: { store.temporaryTrade.fee == 0 ? nil : store.temporaryTrade.fee },
                        set: { store.temporaryTrade.fee = $0 ?? 0 }
                    ), format: .number)
                    .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField(
                        "Optional note",
                        text: .init(get: { store.temporaryTrade.note }, set: { store.send(.binding(.set(\.temporaryTrade.note, $0))) })
                    )
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Validation Error Section
            if let errorMessage = validationError {
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
            
            Section {
                TradeCellView(trade: store.temporaryTrade)
            } header: {
                Text("Preview")
            }
        }
    }
}
