//
//  StatView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

public struct StatNavigationView: View {
    @Bindable public var store: StoreOf<StatNavigationStore>
    
    public init(store: StoreOf<StatNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("hello world")
            }
            .padding()
            .navigationTitle("통계")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
