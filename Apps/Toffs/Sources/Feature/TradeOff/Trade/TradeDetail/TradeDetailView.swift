//
//  TradeDetailView.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import SwiftUI
import ComposableArchitecture

public struct TradeDetailView: View {
    @Bindable public var store: StoreOf<TradeDetailStore>
    
    // 포매터
    private let numFmt: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.numberStyle = .decimal
        return f
    }()
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
    
    private func s(_ v: Double) -> String {
        numFmt.string(from: NSNumber(value: v)) ?? String(v)
    }
    
    public init(store: StoreOf<TradeDetailStore>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            // 거래 기본 정보 섹션
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // 거래 타입과 총 금액
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Trade Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: store.trade.side == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .foregroundColor(store.trade.side == .buy ? .green : .red)
                                    .font(.title2)
                                
                                Text(store.trade.side.displayText)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(store.trade.side == .buy ? .green : .red)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Total Amount")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(s(store.totalAmount)) \(store.trade.ticker?.currency.displayText ?? "")")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // 거래 상세 정보
                    VStack(spacing: 12) {
                        tradeDetailRow(title: "Price", value: s(store.trade.price), unit: store.trade.ticker?.currency.displayText ?? "")
                        tradeDetailRow(title: "Quantity", value: s(store.trade.quantity), unit: "")
                        
                        if store.trade.fee > 0 {
                            tradeDetailRow(title: "Fee", value: s(store.trade.fee), unit: store.trade.ticker?.currency.displayText ?? "", color: .orange)
                        }
                        
                        tradeDetailRow(title: "Date", value: dateFormatter.string(from: store.trade.date), unit: "")
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Trade Information")
            }
            
            // 노트 섹션
            if !store.trade.note.isEmpty {
                Section {
                    Text(store.trade.note)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                } header: {
                    Text("Note")
                }
            }
            
            // 이미지 섹션
            if !store.tradeImages.isEmpty {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Array(store.tradeImages.enumerated()), id: \.offset) { index, image in
                            Button {
                                store.send(.showImageDetail(index))
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Images (\(store.tradeImages.count))")
                }
            }
            

        }
        .navigationTitle(store.trade.ticker?.name ?? "Trade Detail")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        store.send(.editTradeButtonTapped)
                    } label: {
                        HStack {
                            Text("Edit Trade")
                            Image(systemName: "pencil")
                        }
                    }
                    
                    Button(role: .destructive) {
                        store.send(.deleteTradeButtonTapped)
                    } label: {
                        HStack {
                            Text("Delete Trade")
                            Image(systemName: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .fullScreenCover(isPresented: $store.isShowingImageDetail) {
            ImageDetailView(
                images: store.tradeImages,
                selectedIndex: $store.selectedImageIndex,
                isPresented: $store.isShowingImageDetail
            )
        }
        .sheet(item: $store.scope(state: \.addTickerNavigation, action: \.addTickerNavigation)) { store in
            AddTickerNavigationView(store: store)
        }
        .sheet(item: $store.scope(state: \.addTradeNavigation, action: \.addTradeNavigation)) { store in
            AddTradeNavigationView(store: store)
        }
    }
    
    // MARK: - Helper Views
    
    private func tradeDetailRow(title: String, value: String, unit: String, color: Color = .primary) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Image Detail View
struct ImageDetailView: View {
    let images: [UIImage]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationTitle("Image \(selectedIndex + 1) of \(images.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
