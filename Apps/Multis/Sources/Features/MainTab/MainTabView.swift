//
//  MainTabView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture
import CommonFeature

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
            
            DocumentNavigationView(
                store: store.scope(state: \.documents, action: \.documents)
            )
            .tabItem {
                Image(systemName: MainTab.documents.systemImage)
            }
            .tag(MainTab.documents)
            
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
