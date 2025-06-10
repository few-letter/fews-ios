//
//  FolderListCellView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

struct FolderListCellView: View {
    @Bindable var store: StoreOf<FolderListCellStore>
    
    var body: some View {
        Button(action: {
            store.send(.tapped)
        }) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.folder.name ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(store.plotCount) memos")
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
