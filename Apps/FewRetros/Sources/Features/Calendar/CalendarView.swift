import SwiftUI
import ComposableArchitecture
import DS

public struct CalendarView: View {
    let store: StoreOf<CalendarFeature>
    
    public init(store: StoreOf<CalendarFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // 캘린더 섹션
                DSCard(cardShadow: .sm) {
                    DSCardBody {
                        calendarSection
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                
                // KPT 리스트 섹션
                ScrollView {
                    VStack(spacing: DS.Spacing.md) {
                        // KEEP 섹션
                        kptSection(
                            title: "KEEP",
                            color: DS.Colors.Green._500,
                            backgroundColor: DS.Colors.Green._100,
                            records: store.selectedDoc?.keeps ?? [],
                            newText: store.newKeep,
                            placeholder: "유지해야 할 것들을 입력하세요",
                            onTextChange: { store.send(.inputRecord(type: .keep, context: $0)) },
                            onSubmit: { store.send(.commitRecord(type: .keep)) },
                            onDelete: { store.send(.deleteRecord(type: .keep, offset: $0)) }
                        )
                        
                        // PROBLEM 섹션
                        kptSection(
                            title: "PROBLEM",
                            color: DS.Colors.Orange._500,
                            backgroundColor: DS.Colors.Orange._100,
                            records: store.selectedDoc?.problems ?? [],
                            newText: store.newProblem,
                            placeholder: "개선이 필요한 문제점들을 입력하세요",
                            onTextChange: { store.send(.inputRecord(type: .problem, context: $0)) },
                            onSubmit: { store.send(.commitRecord(type: .problem)) },
                            onDelete: { store.send(.deleteRecord(type: .problem, offset: $0)) }
                        )
                        
                        // TRY 섹션
                        kptSection(
                            title: "TRY",
                            color: DS.Colors.Blue._500,
                            backgroundColor: DS.Colors.Blue._100,
                            records: store.selectedDoc?.tries ?? [],
                            newText: store.newTry,
                            placeholder: "다음에 시도해볼 것들을 입력하세요",
                            onTextChange: { store.send(.inputRecord(type: .try, context: $0)) },
                            onSubmit: { store.send(.commitRecord(type: .try)) },
                            onDelete: { store.send(.deleteRecord(type: .try, offset: $0)) }
                        )
                        
                        Spacer(minLength: DS.Spacing.xl)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.md)
                }
                .refreshable {
                    store.send(.refresh)
                }
            }
            .background(DS.Colors.background)
            .id(store.id)
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDisappear)
            }
        }
    }
}

private extension CalendarView {
    var calendarSection: some View {
        LazyVGrid(
            columns: .init(repeating: .init(.flexible()), count: 7),
            spacing: DS.Spacing.xs
        ) {
            // 요일 헤더
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(DS.Typography.smallMedium)
                    .foregroundColor(DS.Colors.content2)
                    .frame(height: 30)
            }
            
            // 캘린더 날짜들
            ForEach(store.docs) { doc in
                CalendarCell(doc: doc)
                    .frame(height: 44)
                    .onTapGesture {
                        store.send(.docTapped(doc))
                    }
            }
        }
    }
    
    func kptSection(
        title: String,
        color: Color,
        backgroundColor: Color,
        records: [Record],
        newText: String,
        placeholder: String,
        onTextChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void,
        onDelete: @escaping (IndexSet) -> Void
    ) -> some View {
        DSCard(cardShadow: .sm) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                // 섹션 헤더
                DSCardHeader {
                    HStack {
                        Text(title)
                            .font(DS.Typography.bodyMedium)
                            .foregroundColor(color)
                        
                        Spacer()
                        
                        Text("\(records.count)")
                            .font(DS.Typography.smallMedium)
                            .foregroundColor(color)
                            .padding(.horizontal, DS.Spacing.sm)
                            .padding(.vertical, DS.Spacing.xs)
                            .background(backgroundColor)
                            .clipShape(Capsule())
                    }
                }
                
                DSCardBody {
                    VStack(spacing: DS.Spacing.sm) {
                        // 기존 레코드들
                        ForEach(Array(records.enumerated()), id: \.element.persistentModelID) { index, record in
                            HStack {
                                Text(record.context ?? "")
                                    .font(DS.Typography.bodyRegular)
                                    .foregroundColor(DS.Colors.content1)
                                
                                Spacer()
                            }
                            .padding(DS.Spacing.sm)
                            .background(DS.Colors.surface)
                            .cornerRadius(DS.Radius.md)
                            .swipeActions(edge: .trailing) {
                                Button("Delete") {
                                    onDelete(IndexSet(integer: index))
                                }
                                .tint(DS.Colors.danger)
                            }
                        }
                        
                        // 새 입력 필드
                        DSInput(
                            text: Binding(
                                get: { newText },
                                set: { onTextChange($0) }
                            ),
                            placeholder: placeholder,
                            variant: .bordered,
                            startIcon: Image(systemName: "plus.circle.fill")
                        )
                        .onSubmit {
                            onSubmit()
                        }
                    }
                }
            }
        }
    }
}

struct CalendarCell: View {
    let doc: Doc
    
    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            Text("\(Calendar.current.component(.day, from: doc.date))")
                .font(DS.Typography.smallMedium)
                .foregroundColor(isSelected ? .white : DS.Colors.content1)
            
            if !doc.records.isEmpty {
                Circle()
                    .fill(isSelected ? .white : DS.Colors.primary)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(isSelected ? DS.Colors.primary : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(
                    isToday ? DS.Colors.primary : Color.clear,
                    lineWidth: isToday ? 2 : 0
                )
        )
        .animation(DS.Animation.fast, value: isSelected)
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(doc.date, inSameDayAs: doc.selectedDate)
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(doc.date, inSameDayAs: Date())
    }
} 
