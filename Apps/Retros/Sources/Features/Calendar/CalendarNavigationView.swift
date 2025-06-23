//
//  HomeView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

public struct CalendarNavigationView: View {
    @Bindable public var store: StoreOf<CalendarNavigationStore>
    
    public init(store: StoreOf<CalendarNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            
        }
    }
}

extension CalendarNavigationView {
    private var mainView: some View {
        VStack {
            
        }
    }
}
