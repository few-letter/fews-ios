//
//  AddPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

public struct AddPlotView: View {
    @Bindable public var store: StoreOf<AddPlotStore>
    
    @Environment(\.colorScheme) var colorScheme
    @State private var calendarId: UUID = UUID()
    @State private var isScrolled: Bool = false
    @State private var textEditorContent: String = ""
    
    public var body: some View {
        ZStack {
            // 메인 TextEditor
            VStack(spacing: 0) {
                // 헤더 공간 확보
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: isScrolled ? 60 : 200)
                    .animation(.easeInOut(duration: 0.2), value: isScrolled)
                
                // TextEditor with scroll detection
                ScrollViewWithOffset(
                    onOffsetChange: { offset in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isScrolled = offset > 150
                        }
                    }
                ) {
                    VStack(spacing: 0) {
                        // 패딩용 공간
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 20)
                        
                        TextEditor(text: $store.plot.content)
                        .font(.body)
                        .frame(minHeight: 400)
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            
            // 오버레이 헤더
            VStack {
                if isScrolled {
                    stickyHeaderView
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    fullHeaderView
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.plot.date) {
            calendarId = UUID()
        }
    }
    
    private var fullHeaderView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 10) {
                    titleField
                    plotControls
                }
                Spacer()
                plotTypeSelector
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            Divider()
                .padding(.horizontal)
        }
    }
    
    private var stickyHeaderView: some View {
        HStack {
            Text(store.plot.title.isEmpty ? "Title" : store.plot.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(store.plot.title.isEmpty ? .secondary : .primary)
            
            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text("\(store.plot.point, specifier: "%.1f")")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            if let plotType = PlotType.allCases.first(where: { $0.rawValue == store.plot.type }) {
                Text(plotType.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
    
    private var titleField: some View {
        TextField("Title", text: $store.plot.title)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
    
    private var plotControls: some View {
        HStack(spacing: 10) {
            starRatingView
            Text("\(store.plot.point, specifier: "%.1f")")
                .font(.subheadline)
                .fontWeight(.semibold)
            resetButton
            datePicker
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
        }, label: {
            Image(systemName: "arrow.counterclockwise")
                .imageScale(.small)
                .foregroundColor(Color(.label))
        })
    }
    
    private var datePicker: some View {
        DatePicker(
            "",
            selection: $store.plot.date,
            displayedComponents: [.date]
        )
        .id(calendarId)
    }
    
    private var plotTypeSelector: some View {
        VStack(alignment: .leading) {
            ForEach(PlotType.allCases, id: \.self) { type in
                HStack {
                    Button(
                        action: {
                            store.send(.binding(.set(\.plot.type, type.rawValue)), animation: .default)
                        },
                        label: {
                            Image(systemName: store.plot.type == type.rawValue ? "circle.fill" : "circle")
                                .imageScale(.small)
                                .font(.footnote)
                                .foregroundColor(Color(.label))
                        }
                    )
                    Text(type.title)
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct StarRatingView: View {
    let point: Double
    let onPointChanged: (Double) -> Void
    
    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        
        return stars
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .frame(width: 80)
            .overlay(starOverlay(stars: stars))
            .foregroundColor(.gray)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let scaledX = max(0, min(100, value.location.x))
                let newPoint = round(scaledX / 100.0 * 5 * 10) / 10
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

// 스크롤 오프셋 감지를 위한 헬퍼 뷰
struct ScrollViewWithOffset<Content: View>: View {
    let onOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ZStack(alignment: .top) {
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minY) { offset in
                            onOffsetChange(-offset)
                        }
                }
                .frame(height: 0)
                
                content()
            }
        }
    }
}
