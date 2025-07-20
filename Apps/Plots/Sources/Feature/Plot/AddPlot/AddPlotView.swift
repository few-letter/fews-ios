//
//  AddPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture
import Vision

public struct AddPlotView: View {
    @Bindable public var store: StoreOf<AddPlotStore>
    
    @State private var calendarId: UUID = UUID()
    @State private var showingLiveCamera = false
    @State private var recognizedTexts: [RecognizedText] = []
    @State private var selectedImage: UIImage?
    @State private var showingTextSelectionSheet = false
    @State private var showingDatePicker = false
    @State private var quoteToDelete: QuoteModel?
    @State private var showingDeleteAlert = false
    
    public var body: some View {
        VStack(spacing: 0) {
            // 개선된 헤더 영역
            improvedHeaderView
                .background(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 10)
                    
                    quotesSection
                    
                    TextEditor(text: $store.plot.content)
                        .font(.body)
                        .frame(minHeight: 300)
                        .padding(.horizontal, 8)
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.plot.date) {
            calendarId = UUID()
        }
        .sheet(isPresented: $showingLiveCamera) {
            NavigationView {
                LiveCameraView { selectedText in
                    addQuote(with: selectedText)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingLiveCamera = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                DatePicker(
                    "Select Date",
                    selection: $store.plot.date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Delete Quote", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let quote = quoteToDelete {
                    deleteQuote(quote)
                }
                quoteToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this quote?")
        }
    }
    
    private var improvedHeaderView: some View {
        VStack(spacing: 12) {
            // First row: Title
            titleField
            
            // Second row: Page, Date, Type
            HStack(spacing: 12) {
                pageProgressField
                customDatePickerButton
                Spacer()
                plotTypeMenu
            }
            
            // Third row: Star Rating
            HStack(spacing: 12) {
                starRatingView
                Text("\(store.plot.point, specifier: "%.1f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                resetButton
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
    }
    
    private var titleField: some View {
        TextField("Enter title", text: $store.plot.title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.vertical, 4)
    }
    
    // plotControls는 3줄 레이아웃으로 분리되어 제거됨
    
    private var pageProgressField: some View {
        HStack(spacing: 4) {
            // Current page field
            TextField("1", value: Binding(
                get: { store.plot.currentPage },
                set: { newValue in
                    store.send(.binding(.set(\.plot.currentPage, newValue)))
                }
            ), format: .number)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.caption)
            .frame(width: 30)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .keyboardType(.numberPad)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            Text("/")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Total pages field
            TextField("100", value: Binding(
                get: { store.plot.totalPages },
                set: { newValue in
                    store.send(.binding(.set(\.plot.totalPages, newValue)))
                }
            ), format: .number)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.caption)
            .frame(width: 35)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .keyboardType(.numberPad)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var starRatingView: some View {
        StarRatingView(
            point: store.plot.point,
            onPointChanged: { point in
                store.send(.binding(.set(\.plot.point, point)))
            }
        )
    }
    
    private var resetButton: some View {
        Button(action: {
            store.send(.binding(.set(\.plot.point, 0)), animation: .default)
        }) {
            Image(systemName: "arrow.counterclockwise")
                .imageScale(.small)
                .foregroundColor(.secondary)
                .padding(4)
        }
    }
    
    private var customDatePickerButton: some View {
        Button(action: {
            showingDatePicker = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.subheadline)
                
                Text(dateFormatter.string(from: store.plot.date))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }
    
    private var plotTypeMenu: some View {
        Menu {
            ForEach(PlotType.allCases, id: \.self) { type in
                Button(action: {
                    store.send(.binding(.set(\.plot.type, type.rawValue)), animation: .default)
                }) {
                    HStack {
                        Text(type.title)
                        if store.plot.type == type.rawValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let selectedType = PlotType.allCases.first(where: { $0.rawValue == store.plot.type }) {
                    Text(selectedType.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var quotesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Memorable Quotes")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 6) {
                    Button(action: {
                        showingLiveCamera = true
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    
                    Button(action: {
                        let newQuote = QuoteModel()
                        var updatedQuotes = store.plot.quotes
                        updatedQuotes.append(newQuote)
                        store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            if store.plot.quotes.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "quote.bubble")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No quotes added yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tap + button to add memorable quotes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal, 12)
            } else {
                ForEach(store.plot.quotes, id: \.id) { quote in
                    quoteRow(for: quote)
                }
            }
        }
    }
    
    private func quoteRow(for quote: QuoteModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                // Page number section
                HStack(spacing: 2) {
                    Text("p.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    TextField("", value: Binding(
                        get: { quote.page },
                        set: { newValue in
                            var updatedQuotes = store.plot.quotes
                            if let index = updatedQuotes.firstIndex(where: { $0.id == quote.id }) {
                                updatedQuotes[index].page = newValue
                                store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.caption2)
                    .frame(width: 30)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(2)
                }
                .frame(width: 50)
                
                Spacer()
                
                // Menu button
                Menu {
                    Button(role: .destructive, action: {
                        quoteToDelete = quote
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: 24, height: 24)
                }
            }
            
            // Multi-line quote text field
            TextField("Enter quote", text: Binding(
                get: { quote.quote },
                set: { newValue in
                    var updatedQuotes = store.plot.quotes
                    if let index = updatedQuotes.firstIndex(where: { $0.id == quote.id }) {
                        updatedQuotes[index].quote = newValue
                        store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
                    }
                }
            ), axis: .vertical) // 여러 줄 지원
            .textFieldStyle(PlainTextFieldStyle())
            .font(.subheadline)
            .lineLimit(1...10) // 최소 1줄, 최대 10줄
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal, 12)
    }
    

    
    private func addQuote(with text: String) {
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newQuote = QuoteModel(quote: text.trimmingCharacters(in: .whitespacesAndNewlines))
            var updatedQuotes = store.plot.quotes
            updatedQuotes.append(newQuote)
            store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
        }
        selectedImage = nil
        recognizedTexts = []
        showingTextSelectionSheet = false
        showingLiveCamera = false
    }
    
    private func deleteQuote(_ quote: QuoteModel) {
        var updatedQuotes = store.plot.quotes
        updatedQuotes.removeAll { $0.id == quote.id }
        store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
    }
}

// 카메라 관련 컴포넌트들은 CameraViews.swift로 분리되었습니다.

struct StarRatingView: View {
    let point: Double
    let onPointChanged: (Double) -> Void
    
    var body: some View {
        let stars = HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        
        stars
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .frame(width: 90, height: 18)
            .overlay(starOverlay(stars: stars))
            .foregroundColor(.gray.opacity(0.3))
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let scaledX = max(0, min(90, value.location.x))
                let newPoint = round(scaledX / 90.0 * 5 * 10) / 10
                onPointChanged(newPoint)
            }
    }
    
    private func starOverlay(stars: some View) -> some View {
        GeometryReader { geometry in
            let width = point / 5.0 * geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: width)
                    .foregroundColor(.yellow)
            }
        }
        .mask(stars)
    }
}
