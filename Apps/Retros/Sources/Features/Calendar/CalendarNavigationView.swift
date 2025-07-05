//
//  CalendarNavigationView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture
import Feature_Common

public struct CalendarNavigationView: View {
    @Bindable public var store: StoreOf<CalendarNavigationStore>
    
    public init(store: StoreOf<CalendarNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension CalendarNavigationView {
    private var mainView: some View {
        calendarView
            .overlay {
                AddRecordPresentationView(store: store.scope(state: \.addRecordPresentation, action: \.addRecordPresentation))
            }
    }
    
    private var calendarView: some View {
        CollapsibleCalendarView(
            itemProvider: { date in
                return store.recordsByDate[date]?.elements ?? []
            },
            onDateChanged: { date in
                store.send(.dateChanged(date))
            },
            cellContent: { date, items, isSelected, isToday, isInCurrentMonth, height in
                CalendarCellContent(
                    date: date,
                    records: items,
                    isSelected: isSelected,
                    isToday: isToday,
                    isInCurrentMonth: isInCurrentMonth,
                    height: height
                )
            },
            handleContent: {
                calendarHandleView
            },
            eventListContent: { records in
                calendarEventListView(records: records)
            })
    }
    
    private var calendarHandleView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 44, height: 4)
            
            HStack {
                Spacer()
                Button(action: {
                    store.send(.plusButtonTapped)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func calendarEventListView(records: [RecordModel]) -> some View {
        List {
            ForEach(records) { record in
                Button {
                    store.send(.tap(record))
                } label: {
                    RecordCellView(record: record)
                }
            }
            .onDelete { store.send(.delete($0)) }
        }
        .listStyle(.plain)
    }
}

private struct CalendarCellContent: View {
    let date: Date
    let records: [RecordModel]
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
                .frame(height: 20)
            
            if height > 40 {
                fullRecordList
            } else {
                compactRecordIndicator
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
                    .frame(width: 20, height: 20)
            }
            
            Text("\(dayNumber)")
                .font(.system(size: height > 40 ? 11 : 13, weight: .medium))
                .foregroundStyle(dayNumberTextColor)
        }
    }
    
    private var compactRecordIndicator: some View {
        Group {
            if !records.isEmpty {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 3, height: 3)
            }
        }
    }
    
    private var fullRecordList: some View {
        VStack(spacing: 0.5) {
            ForEach(Array(records.prefix(3).enumerated()), id: \.offset) { index, record in
                HStack(spacing: 2) {
                    Circle()
                        .fill(recordTypeColor(for: record))
                        .frame(width: 4, height: 4)
                    
                    Text(recordDisplayText(for: record))
                        .font(.system(size: 7))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if records.count > 3 {
                Text("•••")
                    .font(.system(size: 7))
                    .foregroundColor(.accentColor)
                    .padding(.top, 1)
            }
        }
    }
    
    private var dayNumberTextColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return isInCurrentMonth ? .primary : .secondary.opacity(0.5)
    }
    
    private func recordDisplayText(for record: RecordModel) -> String {
        return String(record.context.prefix(8))
    }
    
    private func recordTypeColor(for record: RecordModel) -> Color {
        return record.type.color
    }
}
