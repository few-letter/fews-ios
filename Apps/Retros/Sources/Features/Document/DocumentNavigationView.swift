//
//  DocumentView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

public struct DocumentNavigationView: View {
    @Bindable public var store: StoreOf<DocumentNavigationStore>
    
    public init(store: StoreOf<DocumentNavigationStore>) {
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

extension DocumentNavigationView {
    private var mainView: some View {
        VStack {
            
        }
    }
}
