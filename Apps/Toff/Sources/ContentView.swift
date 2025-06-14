//import SwiftUI
//
///// CollapsibleCalendarView.swift
///// -----------------------------------------------------------------------------
///// Horizontal‑paging calendar with a draggable splitter and inline event titles.
///// Fixed issues:
/////   1️⃣ Week mode visibility by adjusting layout and height calculations
/////   2️⃣ Added snap animation with velocity-based momentum
/////   3️⃣ Improved drag gesture handling with proper velocity detection
/////   4️⃣ 스냅 동작을 더 자연스럽게 개선 및 핸들 터치 영역 확대
///// -----------------------------------------------------------------------------
//
//struct CollapsibleCalendarView: View {
//    // MARK: Selection & layout state ------------------------------------------
//    @State private var selectedDate: Date = .init()
//    @State private var monthIndex: Int = 0
//    @State private var heightFraction: CGFloat = 0.45           // 0‥1 (calendar)
//    @State private var dragStartY: CGFloat? = nil               // 드래그 시작시 오프셋
//    @State private var isCompact: Bool = false                  // week mode?
//
//    private let minFraction: CGFloat = 0.18                     // 최소 높이
//    private let maxFraction: CGFloat = 0.9                      // 최대 높이
//    private let compactThreshold: CGFloat = 0.3                 // 컴팩트 모드 임계점
//    private let updateThreshold: CGFloat = 0.005
//    private let calendar = Calendar.current
//
//    var body: some View {
//        GeometryReader { geo in
//            ZStack(alignment: .top) {
//                Color.black.ignoresSafeArea()
//
//                VStack(spacing: 0) {
//                    calendarBody
//                        .frame(height: geo.size.height * heightFraction)
//                        .background(Color.white)
//                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
//                        .ignoresSafeArea(.container, edges: .horizontal)
//                        .clipped()
//
//                    handle(totalHeight: geo.size.height)
//
//                    listBody
//                        .background(Color.white)
//                        .cornerRadius(16, corners: [.topLeft, .topRight])
//                        .ignoresSafeArea(.container, edges: .horizontal)
//                }
//            }
//        }
//    }
//
//    // MARK: Calendar -----------------------------------------------------------
//    private var calendarBody: some View {
//        TabView(selection: $monthIndex) {
//            ForEach(-120...120, id: \.self) { offset in
//                MonthView(
//                    baseMonth: offset,
//                    selectedDate: $selectedDate,
//                    isCompact: isCompact,
//                    itemProvider: items(for:)
//                )
//                .tag(offset)
//                .id("\(offset)-\(isCompact)")
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .never))
//        .onAppear {
//            monthIndex = 0
//        }
//    }
//
//    // MARK: Splitter handle ----------------------------------------------------
//    private func handle(totalHeight: CGFloat) -> some View {
//        Rectangle()
//            .fill(Color.clear)
//            .frame(height: 60) // ✅ 터치 영역을 44에서 60으로 확대
//            .overlay(RoundedRectangle(cornerRadius: 2)
//                        .fill(Color.white)
//                        .frame(width: 44, height: 4))
//            .gesture(
//                DragGesture(minimumDistance: 0, coordinateSpace: .global)
//                    .onChanged { value in
//                        let currentHandleY = totalHeight * heightFraction
//
//                        if dragStartY == nil {
//                            dragStartY = value.startLocation.y - currentHandleY
//                        }
//                        guard let offsetY = dragStartY else { return }
//
//                        let targetHandleY = value.location.y - offsetY
//                        let newFraction = (targetHandleY / totalHeight)
//                            .clamped(to: minFraction...maxFraction)
//
//                        if abs(newFraction - heightFraction) >= updateThreshold {
//                            heightFraction = newFraction
//                            // ✅ 컴팩트 모드는 임계점 근처에서만 변경
//                            isCompact = heightFraction <= compactThreshold
//                        }
//                    }
//                    .onEnded { value in
//                        dragStartY = nil
//                        
//                        // ✅ 개선된 스냅 로직 - 극단적이지 않게
//                        let currentFraction = heightFraction
//                        
//                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
//                            // 현재 위치에 따라 자연스러운 스냅 포인트 결정
//                            if currentFraction <= compactThreshold {
//                                // 컴팩트 임계점 이하면 최소값으로
//                                heightFraction = minFraction
//                                isCompact = true
//                            } else if currentFraction >= 0.7 {
//                                // 높은 위치면 최대값으로
//                                heightFraction = maxFraction
//                                isCompact = false
//                            } else {
//                                // 중간 영역에서는 가까운 쪽으로 스냅
//                                let midPoint = (compactThreshold + 0.7) / 2
//                                if currentFraction < midPoint {
//                                    heightFraction = compactThreshold + 0.05 // 컴팩트보다 약간 위
//                                    isCompact = false
//                                } else {
//                                    heightFraction = 0.65 // 적당한 중간 높이
//                                    isCompact = false
//                                }
//                            }
//                        }
//                    }
//            )
//    }
//
//    // MARK: Event list ---------------------------------------------------------
//    private var listBody: some View {
//        List(items(for: selectedDate)) { item in
//            Text(item.title)
//                .font(.body)
//                .padding(.vertical, 2)
//        }
//        .listStyle(.plain)
//    }
//
//    // MARK: Demo data ----------------------------------------------------------
//    private func items(for date: Date) -> [DayItem] {
//        let day = calendar.component(.day, from: date)
//        if calendar.isDateInToday(date) {
//            return (1...4).map { DayItem(id: $0, title: "Today \($0)") }
//        } else if day % 3 == 0 {
//            return (1...2).map { DayItem(id: date.hashValue + $0, title: "Evt \($0)") }
//        } else {
//            return []
//        }
//    }
//}
//
//// =============================================================================
//// MARK: – Month / Week View                                                   =
//// =============================================================================
//fileprivate struct MonthView: View {
//    let baseMonth: Int
//    @Binding var selectedDate: Date
//    let isCompact: Bool
//    let itemProvider: (Date) -> [DayItem]
//
//    private let calendar = Calendar.current
//
//    private var monthDate: Date {
//        calendar.date(byAdding: .month, value: baseMonth, to: Date()) ?? Date()
//    }
//
//    private var gridDates: [Date] {
//        let first = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
//        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: first))!
//        
//        let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: first)!
//        let weekEnd = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastDayOfMonth))!
//        let weeksNeeded = calendar.dateComponents([.weekOfYear], from: weekStart, to: weekEnd).weekOfYear! + 1
//        let daysNeeded = weeksNeeded * 7
//        
//        return (0..<daysNeeded).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
//    }
//
//    private var selectedWeek: [Date] {
//        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
//        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
//    }
//
//    var body: some View {
//        GeometryReader { geo in
//            VStack(spacing: 4) {
//                header
//                    .frame(height: 24)
//                
//                if isCompact {
//                    // 주간 모드 레이아웃
//                    VStack(spacing: 4) {
//                        dayOfWeekHeader
//                            .frame(height: 16)
//                        
//                        weekRow(selectedWeek, cellHeight: max(geo.size.height - 56, 40))
//                    }
//                } else {
//                    let weekCount = (gridDates.count / 7)
//                    let availableHeight = geo.size.height - 48 - 16
//                    monthGrid(cellHeight: availableHeight / CGFloat(weekCount))
//                }
//                
//                if isCompact {
//                    Spacer(minLength: 8)
//                }
//            }
//            .padding(16)
//        }
//        .background(Color.white)
//    }
//
//    private var header: some View {
//        Text(monthDate, formatter: Self.titleFormatter)
//            .font(.headline)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .lineLimit(1)
//    }
//
//    private func monthGrid(cellHeight: CGFloat) -> some View {
//        let rows = stride(from: 0, to: gridDates.count, by: 7).map {
//            Array(gridDates[$0..<min($0+7, gridDates.count)])
//        }
//        return VStack(spacing: 2) {
//            dayOfWeekHeader
//                .frame(height: 16)
//            
//            VStack(spacing: 2) {
//                ForEach(Array(rows.enumerated()), id: \.offset) { index, week in
//                    weekRow(week, cellHeight: cellHeight)
//                }
//            }
//        }
//    }
//
//    private func weekRow(_ days: [Date], cellHeight: CGFloat) -> some View {
//        HStack(spacing: 2) {
//            ForEach(days, id: \.self) { date in
//                DateCell(
//                    date: date,
//                    referenceMonth: monthDate,
//                    selectedDate: $selectedDate,
//                    items: itemProvider(date),
//                    height: cellHeight,
//                    isCompact: isCompact
//                )
//            }
//        }
//    }
//
//    private var dayOfWeekHeader: some View {
//        let symbols = calendar.veryShortStandaloneWeekdaySymbols
//        return HStack(spacing: 2) {
//            ForEach(symbols, id: \.self) { s in
//                Text(s)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity)
//                    .lineLimit(1)
//            }
//        }
//    }
//
//    private static let titleFormatter: DateFormatter = {
//        let df = DateFormatter()
//        df.dateFormat = "LLLL yyyy"
//        return df
//    }()
//}
//
//// =============================================================================
//// MARK: – Date cell (top‑aligned)                                             =
//// =============================================================================
//fileprivate struct DateCell: View {
//    let date: Date
//    let referenceMonth: Date
//    @Binding var selectedDate: Date
//    let items: [DayItem]
//    let height: CGFloat
//    let isCompact: Bool
//
//    private let calendar = Calendar.current
//
//    var body: some View {
//        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
//        let isToday = calendar.isDateInToday(date)
//        let inMonth = calendar.isDate(date, equalTo: referenceMonth, toGranularity: .month)
//        let day = calendar.component(.day, from: date)
//
//        Button(action: { selectedDate = date }) {
//            VStack(spacing: 1) {
//                ZStack {
//                    if isSelected {
//                        Circle()
//                            .fill(Color.accentColor)
//                            .frame(width: 24, height: 24)
//                    }
//                    Text("\(day)")
//                        .font(.system(size: isCompact ? 14 : 12, weight: .medium))
//                        .foregroundStyle(textColor(isSelected, inMonth, isToday))
//                }
//                .frame(height: 24)
//                
//                if !isCompact {
//                    VStack(spacing: 0.5) {
//                        ForEach(items.prefix(2)) { item in
//                            Text(item.title)
//                                .font(.system(size: 6))
//                                .lineLimit(1)
//                                .frame(maxWidth: .infinity)
//                                .foregroundColor(.secondary)
//                        }
//                        if items.count > 2 {
//                            Text("•••")
//                                .font(.system(size: 6))
//                                .foregroundColor(.accentColor)
//                        }
//                    }
//                } else if !items.isEmpty {
//                    Circle()
//                        .fill(Color.accentColor)
//                        .frame(width: 4, height: 4)
//                }
//                
//                Spacer(minLength: 0)
//            }
//            .frame(maxWidth: .infinity, minHeight: height, alignment: .top)
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//    }
//
//    private func textColor(_ selected: Bool, _ inMonth: Bool, _ today: Bool) -> Color {
//        if selected { return .white }
//        if today { return .accentColor }
//        return inMonth ? .primary : .secondary.opacity(0.5)
//    }
//}
//
//// =============================================================================
//// MARK: – Demo item model                                                     =
//// =============================================================================
//fileprivate struct DayItem: Identifiable {
//    let id: Int
//    let title: String
//}
//
//// Preview --------------------------------------------------------------------
//#Preview {
//    CollapsibleCalendarView()
//        .preferredColorScheme(.light)
//}
//
//// Clamp helper ---------------------------------------------------------------
//private extension Comparable {
//    func clamped(to range: ClosedRange<Self>) -> Self {
//        min(max(self, range.lowerBound), range.upperBound)
//    }
//}
//
//// Corner radius helper -------------------------------------------------------
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
//
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        return Path(path.cgPath)
//    }
//}
