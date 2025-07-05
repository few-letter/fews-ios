//
//  FolderView.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

import SwiftUI
import ComposableArchitecture

public struct FolderView: View {
    @Bindable var store: StoreOf<FolderStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension FolderView {
    private var mainView: some View {
        list
            .navigationTitle("Folder")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        store.send(.settingButtonTapped)
                    }) {
                        Image(systemName: "gearshape")
                            .imageScale(.medium)
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        store.send(.addFolderButtonTapped)
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .imageScale(.large)
                    }
                    Spacer()
                    Button(action: {
                        store.send(.addPlotButtonTapped)
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(item: $store.scope(state: \.addFolder, action: \.addFolder)) { store in
                AddFolderView(store: store)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    private var list: some View {
        List {
            ForEach(store.folderTypes, id: \.id) { folderType in
                Button(action: {
                    store.send(.folderTypeListCellTapped(folderType))
                }) {
                    FolderTypeListCellView(folderType: folderType)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    if let id = folderType.id {
                        Button(role: .destructive, action: {
                            store.send(.folderTypeListCellDeleteTapped(id))
                        }) {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .refreshable {
            store.send(.refresh)
        }
    }
}
