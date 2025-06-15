//
//  AddTickerView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture

struct AddTickerView: View {
    @Bindable var store: StoreOf<AddTickerStore>
    
    var body: some View {
        NavigationView {
            
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

