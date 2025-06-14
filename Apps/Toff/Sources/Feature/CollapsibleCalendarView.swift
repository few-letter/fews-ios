//
//  CollapsibleCalendarView.swift
//  Toff
//
//  Created by 송영모 on 6/14/25.
//

import SwiftUI

struct CollapsibleCalendarView<Item: CalendarItem, CellContent: View>: View {
    // MARK: - Properties
    @State private var selectedDate: Date = .init()
    @State private var monthIndex: Int = 0
    @State private var heightFraction: CGFloat = 0.45
    @State private var dragStartY: CGFloat? = nil
    @State private var isCompact: Bool = false
    
    private let itemProvider: (Date) -> [Item]
    private let cellContentBuilder: (Date, [Item], Bool, Bool, Bool, CGFloat) -> CellContent
    private let calendar = Calendar.current
    
    // MARK: - Constants
    private let minFraction: CGFloat = 0.18
    private let maxFraction: CGFloat = 0.9
    private let compactThreshold: CGFloat = 0.3
    private let updateThreshold: CGFloat = 0.005
    
    // MARK: - Initializer
    init(
        itemProvider: @escaping (Date) -> [Item],
        @ViewBuilder cellContent: @escaping (
            _ date: Date,
            _ items: [Item],
            _ isSelected: Bool,
            _ isToday: Bool,
            _ isInCurrentMonth: Bool,
            _ height: CGFloat
        ) -> CellContent
    ) {
        self.itemProvider = itemProvider
        self.cellContentBuilder = cellContent
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    calendarBody
                        .frame(height: geo.size.height * heightFraction)
                        .background(Color.white)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(.container, edges: .horizontal)
                        .clipped()
                    
                    splitterHandle(totalHeight: geo.size.height)
                    
                    eventList
                        .background(Color.white)
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(.container, edges: .horizontal)
                }
            }
        }
    }
    
    // MARK: - Calendar Body
    private var calendarBody: some View {
        TabView(selection: $monthIndex) {
            ForEach(-120...120, id: \.self) { offset in
                MonthView<Item, CellContent>(
                    baseMonth: offset,
                    selectedDate: $selectedDate,
                    isCompact: isCompact,
                    itemProvider: itemProvider,
                    cellContentBuilder: cellContentBuilder
                )
                .tag(offset)
                .id("\(offset)-\(isCompact)")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear {
            monthIndex = 0
        }
    }
    
    // MARK: - Splitter Handle
    private func splitterHandle(totalHeight: CGFloat) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: 44, height: 4)
            )
            .gesture(dragGesture(totalHeight: totalHeight))
    }
    
    private func dragGesture(totalHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                handleDragChanged(value: value, totalHeight: totalHeight)
            }
            .onEnded { _ in
                handleDragEnded()
            }
    }
    
    private func handleDragChanged(value: DragGesture.Value, totalHeight: CGFloat) {
        let currentHandleY = totalHeight * heightFraction
        
        if dragStartY == nil {
            dragStartY = value.startLocation.y - currentHandleY
        }
        
        guard let offsetY = dragStartY else { return }
        
        let targetHandleY = value.location.y - offsetY
        let newFraction = (targetHandleY / totalHeight)
            .clamped(to: minFraction...maxFraction)
        
        if abs(newFraction - heightFraction) >= updateThreshold {
            heightFraction = newFraction
            isCompact = heightFraction <= compactThreshold
        }
    }
    
    private func handleDragEnded() {
        dragStartY = nil
        
        let currentFraction = heightFraction
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
            if currentFraction <= compactThreshold {
                heightFraction = minFraction
                isCompact = true
            } else if currentFraction >= 0.7 {
                heightFraction = maxFraction
                isCompact = false
            } else {
                let midPoint = (compactThreshold + 0.7) / 2
                if currentFraction < midPoint {
                    heightFraction = compactThreshold + 0.05
                    isCompact = false
                } else {
                    heightFraction = 0.65
                    isCompact = false
                }
            }
        }
    }
    
    // MARK: - Event List
    private var eventList: some View {
        List(itemProvider(selectedDate)) { item in
            Text(item.displayTitle)
                .font(.body)
                .padding(.vertical, 2)
        }
        .listStyle(.plain)
    }
}

// MARK: - Convenience Initializer for Default Cell
extension CollapsibleCalendarView where CellContent == DefaultDateCellContent<Item> {
    init(itemProvider: @escaping (Date) -> [Item]) {
        self.init(itemProvider: itemProvider) { date, items, isSelected, isToday, isInCurrentMonth, height in
            DefaultDateCellContent(
                date: date,
                items: items,
                isSelected: isSelected,
                isToday: isToday,
                isInCurrentMonth: isInCurrentMonth,
                height: height
            )
        }
    }
}

// MARK: - Default Date Cell Content
struct DefaultDateCellContent<Item: CalendarItem>: View {
    let date: Date
    let items: [Item]
    let isSelected: Bool
    let isToday: Bool
    let isInCurrentMonth: Bool
    let height: CGFloat
    
    private let calendar = Calendar.current
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    var body: some View {
        VStack(spacing: 1) {
            dayNumberView
                .frame(height: 24)
            
            if height > 40 {
                fullEventList
            } else {
                compactEventIndicator
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: height, alignment: .top)
    }
    
    private var dayNumberView: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24)
            }
            
            Text("\(dayNumber)")
                .font(.system(size: height > 40 ? 12 : 14, weight: .medium))
                .foregroundStyle(dayNumberTextColor)
        }
    }
    
    private var compactEventIndicator: some View {
        Group {
            if !items.isEmpty {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 4, height: 4)
            }
        }
    }
    
    private var fullEventList: some View {
        VStack(spacing: 0.5) {
            ForEach(Array(items.prefix(2).enumerated()), id: \.offset) { index, item in
                Text(item.shortTitle)
                    .font(.system(size: 6))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
            
            if items.count > 2 {
                Text("•••")
                    .font(.system(size: 6))
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private var dayNumberTextColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return isInCurrentMonth ? .primary : .secondary.opacity(0.5)
    }
}

// MARK: - Preview
#Preview {
    CollapsibleCalendarView { date in
        DemoCalendarItem.sampleItems(for: date)
    }
    .preferredColorScheme(.light)
}
