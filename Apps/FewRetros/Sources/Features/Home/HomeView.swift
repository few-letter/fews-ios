import SwiftUI
import ComposableArchitecture
import DS

public struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 0) {
                    // 헤더 섹션
                    DSCard(cardShadow: .sm) {
                        DSCardBody {
                            HStack {
                                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                    Text("KPT Reflection")
                                        .font(DS.Typography.h3)
                                        .foregroundColor(DS.Colors.content1)
                                    
                                    Text("\(store.date.year).\(store.date.month)")
                                        .font(DS.Typography.bodyMedium)
                                        .foregroundColor(DS.Colors.primary)
                                }
                                
                                Spacer()
                                
                                EditButton()
                                    .font(DS.Typography.bodyMedium)
                                    .foregroundColor(DS.Colors.primary)
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.sm)
                    
                    // 캘린더 컨텐츠
                    containerView
                        .padding(.top, DS.Spacing.md)
                }
                .background(DS.Colors.background)
                .navigationBarHidden(true)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

private extension HomeView {
    var containerView: some View {
        TabView(selection: Binding(
            get: { store.currentTab },
            set: { store.send(.tabSelected($0)) }
        )) {
            ForEach(store.calendarTabs) { calendarState in
                CalendarView(
                    store: store.scope(
                        state: \.calendarTabs[id: calendarState.id]!,
                        action: \.calendar[id: calendarState.id]
                    )
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

private extension Date {
    var year: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return components.year ?? 0
    }
    
    var month: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: self)
        return components.month ?? 0
    }
} 
