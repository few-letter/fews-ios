//
//  CalendarHome.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

import CommonFeature

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
                AddTradeOffOverlayView(store: store.scope(state: \.addTradeOffOverlay, action: \.addTradeOffOverlay))
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
                CalendarCellContent(
                    date: date,
                    trades: items,
                    isSelected: isSelected,
                    isToday: isToday,
                    isInCurrentMonth: isInCurrentMonth,
                    height: height
                )
            },
            handleContent: {
                calendarHandleView
            },
            eventListContent: { trades in
                calendarEventListView(trades: trades)
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
    
    private func calendarEventListView(trades: [TradeModel]) -> some View {
        List {
            ForEach(trades) { trade in
                Button {
                    store.send(.tap(trade))
                } label: {
                    TradeCellView(trade: trade)
                }
            }
            .onDelete { store.send(.delete($0)) }
        }
        .listStyle(.plain)
    }
}

private struct CalendarCellContent: View {
    let date: Date
    let trades: [TradeModel]
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
                fullTradeList
            } else {
                compactTradeIndicator
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
    
    private var compactTradeIndicator: some View {
        Group {
            if !trades.isEmpty {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 4, height: 4)
            }
        }
    }
    
    private var fullTradeList: some View {
        VStack(spacing: 0.5) {
            ForEach(Array(trades.prefix(2).enumerated()), id: \.offset) { index, trade in
                HStack(spacing: 1) {
                    Rectangle()
                        .fill(trade.side.color)
                        .frame(width: 2, height: 6)
                    
                    Text(tradeDisplayText(for: trade))
                        .font(.system(size: 8))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if trades.count > 2 {
                Text("•••")
                    .font(.system(size: 8))
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private var dayNumberTextColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return isInCurrentMonth ? .primary : .secondary.opacity(0.5)
    }
    
    private func tradeDisplayText(for trade: TradeModel) -> String {
        if let ticker = trade.ticker {
            return ticker.name
        } else {
            return "$\(String(format: "%.0f", trade.price))"
        }
    }
}
