//
//  FolderListCellView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

struct FolderTypeListCellView: View {
    @Bindable var store: StoreOf<FolderTypeListCellStore>
    
    var body: some View {
        Button(action: {
            store.send(.tapped)
        }) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.folderType.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(store.folderType.count) memos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: {
                store.send(.deleteButtonTapped)
            }) {
                Label("Delete Folder", systemImage: "trash")
            }
        }
    }
} 
