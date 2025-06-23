//
//  AddRecordPresentationView.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct AddRecordPresentationView: View {
    @Bindable var store: StoreOf<AddRecordPresentationStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension AddRecordPresentationView {
    private var mainView: some View {
        Color.clear
            .sheet(item: $store.scope(state: \.addRecordNavigation, action: \.addRecordNavigation)) { store in
                AddRecordNavigationView(store: store)
            }
        
    }
}
