//
//  FolderView.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

public struct AddFolderView: View {
    @Bindable var store: StoreOf<AddFolderStore>
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("New Folder", text: $store.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        store.send(.cancel)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        store.send(.confirm)
                    }
                    .disabled(store.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
