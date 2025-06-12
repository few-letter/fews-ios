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
                TextField("Name", text: $store.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        store.send(.cancel)
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        store.send(.confirm)
                    }
                    .disabled(store.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
