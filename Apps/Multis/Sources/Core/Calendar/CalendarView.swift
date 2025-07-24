//
//  CalendarView.swift
//  Multis
//
//  Created by 송영모 on 7/22/25.
//

import SwiftUI
import Feature_Common

public struct CalendarView: View {
    let documentsByDate: [Date: [TimeDocument]]
    let timerModel: any TimerModel
    let onDateChanged: (Date) -> Void
    let onDocumentTapped: (TimeDocument) -> Void
    let onPlusButtonTapped: () -> Void
    let onDeleteDocument: (TimeDocument) -> Void
    
    public init(
        documentsByDate: [Date: [TimeDocument]],
        timerModel: any TimerModel,
        onDateChanged: @escaping (Date) -> Void = { _ in },
        onDocumentTapped: @escaping (TimeDocument) -> Void = { _ in },
        onPlusButtonTapped: @escaping () -> Void = {},
        onDeleteDocument: @escaping (TimeDocument) -> Void = { _ in }
    ) {
        self.documentsByDate = documentsByDate
        self.timerModel = timerModel
        self.onDateChanged = onDateChanged
        self.onDocumentTapped = onDocumentTapped
        self.onPlusButtonTapped = onPlusButtonTapped
        self.onDeleteDocument = onDeleteDocument
    }
    
    public var body: some View {
        CollapsibleCalendarView(
            itemProvider: { date in
                return documentsByDate[date] ?? []
            },
            onDateChanged: onDateChanged,
            cellContent: { date, documents, isSelected, isToday, isInCurrentMonth, height in
                CalendarCellContent(
                    date: date,
                    documents: documents,
                    isSelected: isSelected,
                    isToday: isToday,
                    isInCurrentMonth: isInCurrentMonth,
                    height: height
                )
            },
            handleContent: {
                calendarHandleView
            },
            eventListContent: { documents in
                calendarEventListView(documents: documents)
            }
        )
    }
    
    private var calendarHandleView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 44, height: 4)
            
            HStack {
                Spacer()
                Button(action: onPlusButtonTapped) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func calendarEventListView(documents: [TimeDocument]) -> some View {
        List {
            ForEach(documents) { document in
                Button(action: {
                    onDocumentTapped(document)
                }) {
                    DocumentCellView(
                        document: document,
                        isTimerRunning: timerModel.isTimerRunning(document: document),
                        onTimerToggle: {
                            timerModel.toggleTimer(document: document)
                        }
                    )
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    if index < documents.count {
                        let documentToDelete = documents[index]
                        onDeleteDocument(documentToDelete)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct CalendarCellContent: View {
    let date: Date
    let documents: [TimeDocument]
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
                fullDocumentList
            } else {
                compactDocumentIndicator
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
    
    private var compactDocumentIndicator: some View {
        Group {
            if !documents.isEmpty {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 3, height: 3)
            }
        }
    }
    
    private var fullDocumentList: some View {
        VStack(spacing: 0.5) {
            ForEach(Array(documents.prefix(3).enumerated()), id: \.offset) { index, document in
                HStack(spacing: 2) {
                    Circle()
                        .fill(documentTypeColor(for: document))
                        .frame(width: 4, height: 4)
                    
                    Text(documentDisplayText(for: document))
                        .font(.system(size: 7))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if documents.count > 3 {
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
    
    private func documentDisplayText(for document: TimeDocument) -> String {
        let title = document.title
        return String(title.prefix(8))
    }
    
    private func documentTypeColor(for document: TimeDocument) -> Color {
        switch document {
        case .task(let taskData):
            if let category = taskData.category {
                return Color(hex: category.color) ?? .accentColor
            }
            return .gray
        case .goal(let goalData):
            if let category = goalData.category {
                return Color(hex: category.color) ?? .blue
            }
            return .blue
        }
    }
}

private struct DocumentCellView: View {
    let document: TimeDocument
    let isTimerRunning: Bool
    let onTimerToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 타입 인디케이터
            Circle()
                .fill(documentTypeColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(document.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(documentTypeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(documentTypeColor.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(displayTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onTimerToggle) {
                Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isTimerRunning ? .red : .green)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
    
    private var documentTypeColor: Color {
        switch document {
        case .task(let taskData):
            if let category = taskData.category {
                return Color(hex: category.color) ?? .accentColor
            }
            return .gray
        case .goal(let goalData):
            if let category = goalData.category {
                return Color(hex: category.color) ?? .blue
            }
            return .blue
        }
    }
    
    private var documentTypeText: String {
        switch document {
        case .task:
            return "Task"
        case .goal:
            return "Goal"
        }
    }
    
    private var displayTime: String {
        switch document {
        case .task(let taskData):
            return taskData.displayTime + "s"
        case .goal(let goalData):
            return goalData.todayDisplayTime + "s"
        }
    }
}

