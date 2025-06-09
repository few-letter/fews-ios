//
//  MainView.swift
//  FewCuts
//
//  Created by 송영모 on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

public struct MainTabView: View {
    @Bindable var store: StoreOf<MainTapStore>
    
    public var body: some View {
        TabView(selection: $store.currentTab.sending(\.tab))  {
            NavigationStack {
                HomeView(
                    store: self.store.scope(state: \.home, action: \.home)
                )
            }
            .tag(MainTab.home)
            .tabItem { Text("Home") }
            
            NavigationStack {
                CutsView(
                    store: self.store.scope(state: \.cuts, action: \.cuts)
                )
            }
            .tag(MainTab.cuts)
            .tabItem { Text("Cuts") }
        }
    }
}
