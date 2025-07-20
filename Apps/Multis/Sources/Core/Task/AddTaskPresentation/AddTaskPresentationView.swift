//
//  AddTaskPresentationView.swift
//  Multis
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct AddTaskPresentationView: View {
    @Bindable var store: StoreOf<AddTaskPresentationStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension AddTaskPresentationView {
    private var mainView: some View {
        Color.clear
            .sheet(item: $store.scope(state: \.addTaskNavigation, action: \.addTaskNavigation)) { store in
                AddTaskNavigationView(store: store)
            }
        
    }
}
