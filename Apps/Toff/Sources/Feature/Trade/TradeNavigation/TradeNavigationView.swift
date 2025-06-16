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
                        .disabled(!store.isFormValid)
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
                                    store.send(.binding(.set(\.trade.side, side)))
                                } label: {
                                    HStack {
                                        Image(systemName: side.systemImageName)
                                        Text(side.displayText)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: store.trade.side.systemImageName)
                                    .foregroundColor(.black)
                                Text(store.trade.side.displayText)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
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
                            selection: .init(get: { store.trade.date }, set: { store.send(.set(\.trade.date, $0)) }),
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
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(store.trade.price > 0 ? .green : .gray)
                                    .font(.system(size: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Quantity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(store.trade.quantity > 0 ? .green : .gray)
                                    .font(.system(size: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(spacing: 12) {
                        TextField("Decimal allowed", value: Binding<Double?>(
                            get: { store.trade.price == 0 ? nil : store.trade.price },
                            set: { store.trade.price = $0 ?? 0 }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: .infinity)
                        
                        TextField("Decimal allowed", value: Binding<Double?>(
                            get: { store.trade.quantity == 0 ? nil : store.trade.quantity },
                            set: { store.trade.quantity = $0 ?? 0 }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fee")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Percentage", value: Binding<Double?>(
                        get: { store.trade.fee == 0 ? nil : store.trade.fee },
                        set: { store.trade.fee = $0 ?? 0 }
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
                        text: .init(get: { store.trade.note }, set: { store.send(.set(\.trade.note, $0)) })
                    )
                }
                .padding(.vertical, 4)
            }
            
            Section {
                TradePreviewView(trade: store.trade, ticker: store.ticker)
            } header: {
                Text("Preview")
            }
        }
    }
}
