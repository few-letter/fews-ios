import SwiftUI
import UniformTypeIdentifiers

// MARK: - Models
struct TimeEvent: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var startMinute: Int // 9:00 = 0, 9:10 = 10, etc.
    var endMinute: Int
    var color: Color
    var columnIndex: Int
    
    var startHour: Int {
        (startMinute / 60) + 9
    }
    
    var endHour: Int {
        (endMinute / 60) + 9
    }
    
    var startMinuteInHour: Int {
        startMinute % 60
    }
    
    var endMinuteInHour: Int {
        endMinute % 60
    }
    
    var duration: Int {
        endMinute - startMinute
    }
    
    var timeString: String {
        let startH = startHour
        let startM = startMinuteInHour
        let endH = endHour
        let endM = endMinuteInHour
        return String(format: "%02d:%02d - %02d:%02d", startH, startM, endH, endM)
    }
    
    static func == (lhs: TimeEvent, rhs: TimeEvent) -> Bool {
        lhs.id == rhs.id
    }
}

struct DragState {
    var isActive: Bool = false
    var startMinute: Int = 0
    var currentMinute: Int = 0
    var columnIndex: Int = 0
    
    mutating func reset() {
        isActive = false
        startMinute = 0
        currentMinute = 0
        columnIndex = 0
    }
}

// MARK: - Views
struct TimeSlotView: View {
    let minute: Int // 0 = 9:00, 10 = 9:10, etc.
    let columnIndex: Int
    let events: [TimeEvent]
    @Binding var dragState: DragState
    let onEventCreated: (TimeEvent) -> Void
    let onEventTapped: (TimeEvent) -> Void
    
    private let slotHeight: CGFloat = 10 // 10분당 10pt
    
    var hour: Int {
        (minute / 60) + 9
    }
    
    var minuteInHour: Int {
        minute % 60
    }
    
    var timeString: String {
        String(format: "%02d:%02d", hour, minuteInHour)
    }
    
    var isDragTarget: Bool {
        dragState.isActive &&
        dragState.columnIndex == columnIndex &&
        minute >= min(dragState.startMinute, dragState.currentMinute) &&
        minute <= max(dragState.startMinute, dragState.currentMinute)
    }
    
    var eventsStartingHere: [TimeEvent] {
        events.filter { event in
            event.startMinute == minute && event.columnIndex == columnIndex
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(isDragTarget ? Color.blue.opacity(0.2) : Color.clear)
                .frame(height: slotHeight)
                .overlay(
                    Rectangle()
                        .stroke(
                            Color.gray.opacity(minuteInHour == 0 ? 0.2 : 0.05),
                            lineWidth: minuteInHour == 0 ? 0.5 : 0.3
                        )
                )
            
            // Events starting at this time
            if !eventsStartingHere.isEmpty {
                GeometryReader { geometry in
                    let overlappingEvents = getOverlappingEvents(for: eventsStartingHere.first!)
                    let eventWidth = geometry.size.width / CGFloat(overlappingEvents.count)
                    
                    ForEach(Array(overlappingEvents.enumerated()), id: \.element.id) { index, event in
                        EventView(
                            event: event,
                            slotHeight: slotHeight,
                            width: eventWidth - 1
                        )
                        .offset(x: CGFloat(index) * eventWidth)
                        .onTapGesture {
                            onEventTapped(event)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if !dragState.isActive {
                        // Start new drag
                        dragState.isActive = true
                        dragState.startMinute = minute
                        dragState.currentMinute = minute
                        dragState.columnIndex = columnIndex
                    }
                    
                    // Update current minute based on drag position
                    let deltaY = value.location.y - value.startLocation.y
                    let minuteDelta = Int(deltaY / slotHeight) * 10 // 10분 단위로 스냅
                    dragState.currentMinute = max(0, min(540, dragState.startMinute + minuteDelta)) // 9:00~18:00 = 540분
                }
                .onEnded { _ in
                    if dragState.isActive {
                        let startMinute = min(dragState.startMinute, dragState.currentMinute)
                        let endMinute = max(dragState.startMinute, dragState.currentMinute) + 10
                        
                        if endMinute > startMinute {
                            let newEvent = TimeEvent(
                                title: "새 일정",
                                startMinute: startMinute,
                                endMinute: endMinute,
                                color: randomColor(),
                                columnIndex: columnIndex
                            )
                            onEventCreated(newEvent)
                        }
                        
                        dragState.reset()
                    }
                }
        )
    }
    
    private func getOverlappingEvents(for event: TimeEvent) -> [TimeEvent] {
        let columnEvents = events.filter { $0.columnIndex == columnIndex }
        return columnEvents.filter { otherEvent in
            !(event.endMinute <= otherEvent.startMinute || event.startMinute >= otherEvent.endMinute)
        }
    }
    
    private func randomColor() -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .teal, .indigo]
        return colors.randomElement() ?? .blue
    }
}

struct EventView: View {
    let event: TimeEvent
    let slotHeight: CGFloat
    let width: CGFloat
    
    var shouldShowDetails: Bool {
        width > 40 && CGFloat(event.duration) * slotHeight / 10 > 20
    }
    
    var shouldShowTime: Bool {
        width > 60 && CGFloat(event.duration) * slotHeight / 10 > 30
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            if shouldShowDetails {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(shouldShowTime ? 2 : 3)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                
                if shouldShowTime {
                    Text(event.timeString)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            } else if width > 20 {
                // 중간 크기: 제목만 축약해서 표시
                Text(event.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                // 아주 좁으면 첫 글자만
                Text(String(event.title.prefix(1)))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: shouldShowDetails ? .topLeading : .center)
        .padding(.horizontal, shouldShowDetails ? 4 : 2)
        .padding(.vertical, shouldShowDetails ? 3 : 1)
        .frame(width: width, height: CGFloat(event.duration) * slotHeight / 10 - 1)
        .background(event.color)
        .cornerRadius(3)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

struct ColumnView: View {
    let title: String
    let columnIndex: Int
    let events: [TimeEvent]
    @Binding var dragState: DragState
    let onEventCreated: (TimeEvent) -> Void
    let onEventTapped: (TimeEvent) -> Void
    
    private let minutes = Array(stride(from: 0, to: 540, by: 10)) // 9:00~18:00, 10분 단위
    
    var body: some View {
        VStack(spacing: 0) {
            // Column header
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            
            // Time slots
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(minutes, id: \.self) { minute in
                        TimeSlotView(
                            minute: minute,
                            columnIndex: columnIndex,
                            events: events,
                            dragState: $dragState,
                            onEventCreated: onEventCreated,
                            onEventTapped: onEventTapped
                        )
                    }
                }
            }
            .frame(height: 540) // 고정 높이: 54 슬롯 * 10pt = 540pt
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TimeLabelsView: View {
    private let minutes = Array(stride(from: 0, to: 540, by: 10))
    private let slotHeight: CGFloat = 10
    
    var body: some View {
        VStack(spacing: 0) {
            // Header space
            Text("")
                .font(.headline)
                .padding(.vertical, 12)
                .frame(height: 44)
            
            // Time labels
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(minutes, id: \.self) { minute in
                        let hour = (minute / 60) + 9
                        let minuteInHour = minute % 60
                        
                        HStack {
                            if minuteInHour == 0 {
                                Text("\(hour):00")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                            } else {
                                Text("")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            
                            Spacer()
                        }
                        .frame(height: slotHeight)
                    }
                }
            }
            .frame(height: 540) // 고정 높이
        }
    }
}

// MARK: - Main View
struct KanbanTimetableView: View {
    @State private var events: [TimeEvent] = []
    @State private var dragState = DragState()
    @State private var selectedEvent: TimeEvent?
    @State private var showingEventDetail = false
    
    private let columns = ["월요일", "화요일", "수요일", "목요일", "금요일"]
    
    var body: some View {
        GeometryReader { geometry in
            let timeLabelsWidth: CGFloat = 50 // 70에서 50으로 줄임
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(columns.count - 1)
            let padding: CGFloat = 16
            let availableWidth = geometry.size.width - timeLabelsWidth - totalSpacing - padding
            let columnWidth = availableWidth / CGFloat(columns.count)
            
            HStack(spacing: 0) {
                // Time labels
                TimeLabelsView()
                    .frame(width: timeLabelsWidth)
                
                // Columns - 모든 컬럼이 한 화면에 들어가도록
                HStack(spacing: spacing) {
                    ForEach(columns.indices, id: \.self) { columnIndex in
                        ColumnView(
                            title: columns[columnIndex],
                            columnIndex: columnIndex,
                            events: events,
                            dragState: $dragState,
                            onEventCreated: handleEventCreated,
                            onEventTapped: handleEventTapped
                        )
                        .frame(width: columnWidth)
                    }
                }
                .padding(.horizontal, padding / 2)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailView(event: event) { updatedEvent in
                    updateEvent(updatedEvent)
                } onDelete: {
                    deleteEvent(event)
                }
            }
        }
    }
    
    private func handleEventCreated(_ event: TimeEvent) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            events.append(event)
        }
    }
    
    private func handleEventTapped(_ event: TimeEvent) {
        selectedEvent = event
        showingEventDetail = true
    }
    
    private func updateEvent(_ updatedEvent: TimeEvent) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                events[index] = updatedEvent
            }
        }
        selectedEvent = nil
        showingEventDetail = false
    }
    
    private func deleteEvent(_ event: TimeEvent) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            events.removeAll { $0.id == event.id }
        }
        selectedEvent = nil
        showingEventDetail = false
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    @State private var title: String
    @State private var selectedColor: Color
    private let event: TimeEvent
    private let onSave: (TimeEvent) -> Void
    private let onDelete: () -> Void
    
    private let availableColors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .teal, .indigo]
    
    init(event: TimeEvent, onSave: @escaping (TimeEvent) -> Void, onDelete: @escaping () -> Void) {
        self.event = event
        self.onSave = onSave
        self.onDelete = onDelete
        self._title = State(initialValue: event.title)
        self._selectedColor = State(initialValue: event.color)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(.headline)
                    
                    TextField("일정 제목", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("시간")
                        .font(.headline)
                    
                    Text("\(event.timeString) (\(event.duration)분)")
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("색상")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                Spacer()
                
                Button("삭제", role: .destructive) {
                    onDelete()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("일정 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    onSave(event)
                },
                trailing: Button("저장") {
                    let updatedEvent = TimeEvent(
                        title: title.isEmpty ? "새 일정" : title,
                        startMinute: event.startMinute,
                        endMinute: event.endMinute,
                        color: selectedColor,
                        columnIndex: event.columnIndex
                    )
                    onSave(updatedEvent)
                }
            )
        }
    }
}
