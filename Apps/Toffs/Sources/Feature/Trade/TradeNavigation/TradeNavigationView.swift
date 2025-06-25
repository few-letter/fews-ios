//
//  TradeNavigationView.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

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
                .fullScreenCover(isPresented: $store.isShowingImageDetail) {
                    ImageDetailView(
                        images: tradeImages,
                        selectedIndex: $store.selectedImageIndex,
                        isPresented: $store.isShowingImageDetail
                    )
                }
        } destination: { store in
            
        }
    }
}

extension TradeNavigationView {
    
    // MARK: - Validation Computed Properties
    
    private var validationError: String? {
        return store.trade.validateBalance(in: store.trades)
    }
    
    // MARK: - Image Computed Property
    
    private var tradeImages: [UIImage] {
        return store.trade.images.compactMap { UIImage(from: $0) }
    }
    
    private var isTradeValid: Bool {
        return validationError == nil
    }
    
    // Price - 단순히 값이 있는지만 체크
    private var priceCheckmarkColor: Color {
        if store.trade.price == 0 {
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
        if store.trade.quantity == 0 {
            return .gray
        } else if store.trade.quantity > 0 && isTradeValid {
            return .green
        } else {
            return .red
        }
    }
    
    private var quantityCheckmarkImageName: String {
        if store.trade.quantity == 0 {
            return "checkmark.circle.fill"
        } else if store.trade.quantity > 0 && isTradeValid {
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
                            selection: .init(get: { store.trade.date }, set: { store.send(.binding(.set(\.trade.date, $0))) }),
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
                                get: { store.trade.price == 0 ? nil : store.trade.price },
                                set: { store.send(.binding(.set(\.trade.price, $0 ?? 0))) }
                            ), format: .number)
                            .keyboardType(.decimalPad)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading) {
                            TextField("Decimal allowed", value: Binding<Double?>(
                                get: { store.trade.quantity == 0 ? nil : store.trade.quantity },
                                set: { store.send(.binding(.set(\.trade.quantity, $0 ?? 0))) }
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
                        get: { store.trade.fee == 0 ? nil : store.trade.fee },
                        set: { store.send(.binding(.set(\.trade.fee, $0 ?? 0))) }
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
                        text: .init(get: { store.trade.note }, set: { store.send(.binding(.set(\.trade.note, $0))) })
                    )
                }
                .padding(.vertical, 4)
                
                // MARK: - 이미지 섹션 (Trade Information 내부에 통합)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Images")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        PhotosPicker(
                            selection: Binding(
                                get: { store.selectedPhotos },
                                set: { store.send(.photosSelected($0)) }
                            ),
                            maxSelectionCount: 5,
                            matching: .images
                        ) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        .disabled(store.isLoadingImages)
                    }
                    
                    // 로딩 상태
                    if store.isLoadingImages {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Loading...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 이미지 표시 - 가로 스크롤
                    if !store.trade.images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(tradeImages.enumerated()), id: \.offset) { index, uiImage in
                                    ZStack(alignment: .topTrailing) {
                                        // 이미지 터치 영역
                                        Button {
                                            store.send(.showImageDetail(index))
                                        } label: {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipped()
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        // 삭제 버튼 (별도 버튼으로 분리)
                                        Button {
                                            store.send(.removeImage(index))
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.red)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .padding(.horizontal, 8) // X 버튼이 잘리지 않도록 여백 추가
                            .padding(.vertical, 6) // 상하 여백도 추가
                        }
                        .clipped(antialiased: false) // 스크롤뷰 클리핑 해제
                    }
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
                TradeCellView(trade: store.trade)
            } header: {
                Text("Preview")
            }
        }
    }
}

// MARK: - ImageDetailView
struct ImageDetailView: View {
    let images: [UIImage]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 배경
            Color.black
                .ignoresSafeArea()
            
            // 이미지 뷰
            if !images.isEmpty {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        GeometryReader { geometry in
                            ScrollView([.horizontal, .vertical]) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                    .clipped()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            
            // 닫기 버튼
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding()
        }
        .statusBarHidden()
    }
}
