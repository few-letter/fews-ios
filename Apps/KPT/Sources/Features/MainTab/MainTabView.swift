import SwiftUI
import ComposableArchitecture
import DS

public struct MainTabView: View {
    let store: StoreOf<MainTabFeature>
    
    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // 메인 컨텐츠 영역
                TabView(selection: Binding(
                    get: { store.currentTab },
                    set: { store.send(.tabSelected($0)) }
                )) {
                    HomeView(store: store.scope(state: \.home, action: \.home))
                        .tag(Tab.home)
                    
                    DocView(store: store.scope(state: \.doc, action: \.doc))
                        .tag(Tab.doc)
                    
                    SettingView(store: store.scope(state: \.setting, action: \.setting))
                        .tag(Tab.setting)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // 커스텀 탭 바
                DSCard(cardShadow: .md, radius: DS.Radius.xl, isBlurred: true) {
                    HStack(spacing: DS.Spacing.lg) {
                        Spacer()
                        
                        TabBarButton(
                            icon: "sparkles",
                            title: "Home",
                            isSelected: store.currentTab == .home
                        ) {
                            store.send(.tabSelected(.home))
                        }
                        
                        Spacer()
                        
                        TabBarButton(
                            icon: "doc.text",
                            title: "Docs",
                            isSelected: store.currentTab == .doc
                        ) {
                            store.send(.tabSelected(.doc))
                        }
                        
                        Spacer()
                        
                        TabBarButton(
                            icon: "gearshape.fill",
                            title: "Settings",
                            isSelected: store.currentTab == .setting
                        ) {
                            store.send(.tabSelected(.setting))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, DS.Spacing.sm)
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.sm)
            }
            .background(DS.Colors.background)
        }
    }
}

// MARK: - Custom Tab Bar Button
private struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.content3)
                
                Text(title)
                    .font(DS.Typography.smallMedium)
                    .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.content3)
            }
            .padding(.vertical, DS.Spacing.xs)
            .padding(.horizontal, DS.Spacing.sm)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .fill(DS.Colors.primary.opacity(0.1))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DS.Animation.fast, value: isSelected)
    }
} 
