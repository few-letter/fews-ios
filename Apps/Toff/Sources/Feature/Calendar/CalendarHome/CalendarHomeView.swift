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
        CollapsibleCalendarView(itemProvider: { date in
            return store.tradesByDate[date]?.elements ?? []
        }, onDateChanged: { date in
            store.send(.dateChanged(date))
        }, handleContent: {
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
        })
    }
}
