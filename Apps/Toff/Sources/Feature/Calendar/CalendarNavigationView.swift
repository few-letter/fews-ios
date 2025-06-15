//
//  CalendarView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct CalendarNavigationView: View {
    @Bindable public var store: StoreOf<CalendarNavigationStore>
    
    public init(store: StoreOf<CalendarNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("캘린더")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                DatePicker(
                    "날짜 선택",
                    selection: $store.selectedDate.sending(\.dateSelected),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                
                Spacer()
                
                Text("선택된 날짜: \(store.selectedDate, formatter: dateFormatter)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("캘린더")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
}
