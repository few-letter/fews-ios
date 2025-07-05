//
//  MonthView.swift
//  Toff
//
//  Created by 송영모 on 6/14/25.
//

import SwiftUI

struct MonthView<Item, CellContent: View>: View {
    // MARK: - Properties
    let baseMonth: Int
    @Binding var selectedDate: Date
    let isCompact: Bool
    let itemProvider: (Date) -> [Item]
    let cellContentBuilder: (Date, [Item], Bool, Bool, Bool, CGFloat) -> CellContent
    
    private let calendar = Calendar.current
    
    // MARK: - Computed Properties
    private var monthDate: Date {
        calendar.date(byAdding: .month, value: baseMonth, to: Date()) ?? Date()
    }
    
    private var gridDates: [Date] {
        CalendarDateGenerator.generateDates(for: monthDate, using: calendar)
    }
    
    private var selectedWeek: [Date] {
        CalendarDateGenerator.generateWeekDates(for: selectedDate, using: calendar)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 4) {
                monthHeader
                    .frame(height: 24)
                
                if isCompact {
                    compactWeekView(geometry: geo)
                } else {
                    fullMonthView(geometry: geo)
                }
                
                if isCompact {
                    Spacer(minLength: 8)
                }
            }
            .padding(16)
        }
        .background(Color.white)
    }
    
    // MARK: - Header
    private var monthHeader: some View {
        Text(monthDate, formatter: DateFormatters.monthYear)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
    }
    
    // MARK: - Compact Week View
    private func compactWeekView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 4) {
            dayOfWeekHeader
                .frame(height: 16)
            
            weekRow(
                selectedWeek,
                cellHeight: max(geometry.size.height - 56, 40)
            )
        }
    }
    
    // MARK: - Full Month View
    private func fullMonthView(geometry: GeometryProxy) -> some View {
        let weekCount = (gridDates.count / 7)
        let availableHeight = geometry.size.height - 48 - 16
        let cellHeight = availableHeight / CGFloat(weekCount)
        
        return VStack(spacing: 2) {
            dayOfWeekHeader
                .frame(height: 16)
            
            monthGrid(cellHeight: cellHeight)
        }
    }
    
    // MARK: - Month Grid
    private func monthGrid(cellHeight: CGFloat) -> some View {
        let rows = stride(from: 0, to: gridDates.count, by: 7).map {
            Array(gridDates[$0..<min($0+7, gridDates.count)])
        }
        
        return VStack(spacing: 2) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, week in
                weekRow(week, cellHeight: cellHeight)
            }
        }
    }
    
    // MARK: - Week Row
    private func weekRow(_ days: [Date], cellHeight: CGFloat) -> some View {
        HStack(spacing: 2) {
            ForEach(days, id: \.self) { date in
                CustomDateCell<Item, CellContent>(
                    date: date,
                    referenceMonth: monthDate,
                    selectedDate: $selectedDate,
                    items: itemProvider(date),
                    height: cellHeight,
                    cellContentBuilder: cellContentBuilder
                )
            }
        }
    }
    
    // MARK: - Day of Week Header
    private var dayOfWeekHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        
        return HStack(spacing: 2) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Custom Date Cell Wrapper
struct CustomDateCell<Item, CellContent: View>: View {
    let date: Date
    let referenceMonth: Date
    @Binding var selectedDate: Date
    let items: [Item]
    let height: CGFloat
    let cellContentBuilder: (Date, [Item], Bool, Bool, Bool, CGFloat) -> CellContent
    
    private let calendar = Calendar.current
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var isInCurrentMonth: Bool {
        calendar.isDate(date, equalTo: referenceMonth, toGranularity: .month)
    }
    
    var body: some View {
        Button(action: { selectedDate = date }) {
            cellContentBuilder(date, items, isSelected, isToday, isInCurrentMonth, height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Date Generator
enum CalendarDateGenerator {
    static func generateDates(for monthDate: Date, using calendar: Calendar) -> [Date] {
        let first = calendar.date(
            from: calendar.dateComponents([.year, .month], from: monthDate)
        )!
        
        let weekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: first)
        )!
        
        let lastDayOfMonth = calendar.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: first
        )!
        
        let weekEnd = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastDayOfMonth)
        )!
        
        let weeksNeeded = calendar.dateComponents([.weekOfYear], from: weekStart, to: weekEnd).weekOfYear! + 1
        let daysNeeded = weeksNeeded * 7
        
        return (0..<daysNeeded).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStart)
        }
    }
    
    static func generateWeekDates(for selectedDate: Date, using calendar: Calendar) -> [Date] {
        let start = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        )!
        
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
}
