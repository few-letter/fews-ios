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
                TextField("Name", text: .init(get: { store.folder.name }, set: { store.send(.setName($0)) }))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.send(.confirmButtonTapped)
                    }
                    .disabled(store.folder.name.isEmpty)
                }
            }
        }
    }
}
