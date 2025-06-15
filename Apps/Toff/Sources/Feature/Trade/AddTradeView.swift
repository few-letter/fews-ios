//
//  AddTradeView.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct AddTradeView: View {
    @Bindable var store: StoreOf<AddTradeStore>
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
