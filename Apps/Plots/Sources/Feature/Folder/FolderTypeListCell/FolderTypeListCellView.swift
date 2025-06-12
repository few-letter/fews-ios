//
//  FolderListCellView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

public struct FolderTypeListCellView: View {
    @Bindable var store: StoreOf<FolderTypeListCellStore>
    
    public var body: some View {
        Button(action: {
            store.send(.tapped)
        }) {
            HStack {
                Image(systemName: "folder")
                    .foregroundColor(.blue)
                
                Text(store.folderType.name)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(store.folderType.count)")
                    .foregroundColor(.secondary)
                    .font(.callout)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if let id = store.folderType.id {
                Button(role: .destructive, action: {
                    store.send(.deleteButtonTapped(id))
                }) {
                    Label("Delete Folder", systemImage: "trash")
                }
            }
        }
    }
} 
