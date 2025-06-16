import SwiftUI

struct CollapsibleCalendarView<Item: CalendarItem, CellContent: View, HandleContent: View, EventListContent: View>: View {
    // MARK: - Properties
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var monthIndex: Int = 0
    @State private var heightFraction: CGFloat = 0.45
    @State private var dragStartY: CGFloat? = nil
    @State private var isCompact: Bool = false
    
    private let itemProvider: (Date) -> [Item]
    private let cellContentBuilder: (Date, [Item], Bool, Bool, Bool, CGFloat) -> CellContent
    private let handleContentBuilder: () -> HandleContent
    private let eventListContentBuilder: ([Item]) -> EventListContent
    private let onDateChanged: (Date) -> Void
    private let calendar = Calendar.current
    
    // MARK: - Constants
    private let minFraction: CGFloat = 0.18
    private let maxFraction: CGFloat = 0.9
    private let compactThreshold: CGFloat = 0.3
    private let updateThreshold: CGFloat = 0.005
    
    // MARK: - Initializer
    init(
        itemProvider: @escaping (Date) -> [Item],
        onDateChanged: @escaping (Date) -> Void,
        @ViewBuilder cellContent: @escaping (
            _ date: Date,
            _ items: [Item],
            _ isSelected: Bool,
            _ isToday: Bool,
            _ isInCurrentMonth: Bool,
            _ height: CGFloat
        ) -> CellContent,
        @ViewBuilder handleContent: @escaping () -> HandleContent,
        @ViewBuilder eventListContent: @escaping ([Item]) -> EventListContent
    ) {
        self.itemProvider = itemProvider
        self.onDateChanged = onDateChanged
        self.cellContentBuilder = cellContent
        self.handleContentBuilder = handleContent
        self.eventListContentBuilder = eventListContent
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    calendarBody
                        .frame(height: geo.size.height * heightFraction)
                        .background(Color.white)
                        .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                        .clipped()
                    
                    splitterHandle(totalHeight: geo.size.height)
                    
                    eventList
                        .background(Color.white)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                }
                .background(.black, ignoresSafeAreaEdges: [])
            }
        }
        .onChange(of: selectedDate, initial: true) { oldValue, newValue in
            onDateChanged(newValue)
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
    
    private func splitterHandle(totalHeight: CGFloat) -> some View {
        handleContentBuilder()
            .frame(height: 40)
            .background(.black)
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
    
    private var eventList: some View {
        eventListContentBuilder(itemProvider(selectedDate))
    }
}
