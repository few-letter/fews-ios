//
//  RootView.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

public struct RootView: View {
    public let store: StoreOf<RootStore>
    
    public var body: some View {
        MainTabView(store: self.store.scope(state: \.mainTab, action: \.mainTab))
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    RootView(store: Store(initialState: RootStore.State()) {
        RootStore()
    })
}
