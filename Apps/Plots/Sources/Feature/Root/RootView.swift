//
//  RootView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

public struct RootView: View {
    public let store: StoreOf<RootStore>
    
    public var body: some View {
        HomeView(store: self.store.scope(state: \.home, action: \.home))
            .task {
                await AppOpenAdManager.shared.showAdIfAvailable()
            }
    }
}

#Preview {
    RootView(store: Store(initialState: RootStore.State()) {
        RootStore()
    })
}
