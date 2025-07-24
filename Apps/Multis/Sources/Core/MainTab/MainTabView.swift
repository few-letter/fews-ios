//
//  MainTabView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture
import Feature_Common

public struct MainTabView: View {
    @Bindable public var store: StoreOf<MainTabStore>
    @State public var timerModel: any TimerModel
    @Environment(\.scenePhase) private var scenePhase
    
    public init(store: StoreOf<MainTabStore>) {
        self.store = store
        self.timerModel = MultiTimerModel()
    }
    
    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            CalendarNavigationView(
                store: store.scope(state: \.calendars, action: \.calendars),
                timerModel: timerModel
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
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                timerModel.handleAppWillEnterBackground()
            case .active:
                timerModel.handleAppWillEnterForeground()
            default:
                break
            }
        }
    }
}
