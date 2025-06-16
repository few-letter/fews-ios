//
//  CalendarHome.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct CalendarHomeView: View {
    @Bindable var store: StoreOf<CalendarHomeStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension CalendarHomeView {
    private var mainView: some View {
        calendarView
            .overlay {
                AddTradePresentationView(store: store.scope(state: \.addTradePresentation, action: \.addTradePresentation))
            }
    }
    
    private var calendarView: some View {
        CollapsibleCalendarView(
            itemProvider: { date in
                return store.tradesByDate[date]?.elements ?? []
            },
            onDateChanged: { date in
                store.send(.dateChanged(date))
            },
            cellContent: { date, items, isSelected, isToday, isInCurrentMonth, height in
                DefaultDateCellContent(
                    date: date,
                    items: items,
                    isSelected: isSelected,
                    isToday: isToday,
                    isInCurrentMonth: isInCurrentMonth,
                    height: height
                )
            },
            handleContent: {
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
            },
            eventListContent: { trades in
                List {
                    ForEach(trades) { trade in
                        TradeCellView(trade: trade)
                    }
                    .onDelete { store.send(.delete($0)) }
                }
                .listStyle(.plain)
            })
    }
}

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

