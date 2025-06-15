//
//  RootView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct MainTabView: View {
    @Bindable public var store: StoreOf<MainTabStore>
    
    public init(store: StoreOf<MainTabStore>) {
        self.store = store
    }
    
    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            CalendarNavigationView(
                store: store.scope(state: \.calendars, action: \.calendars)
            )
            .tabItem {
                Image(systemName: MainTab.calendars.systemImage)
            }
            .tag(MainTab.calendars)
            
            StatNavigationView(
                store: store.scope(state: \.stats, action: \.stats)
            )
            .tabItem {
                Image(systemName: MainTab.stats.systemImage)
            }
            .tag(MainTab.stats)
            
            SettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
            .tabItem {
                Image(systemName: MainTab.settings.systemImage)
            }
            .tag(MainTab.settings)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
