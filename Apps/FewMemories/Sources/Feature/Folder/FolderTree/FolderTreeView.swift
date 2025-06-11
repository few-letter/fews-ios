//
//  PlotListView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

public struct FolderTreeView: View {
    @Bindable var store: StoreOf<FolderTreeStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension FolderTreeView {
    private var mainView: some View {
        list
            .navigationTitle(store.folderType.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        if let folder = store.folderType.folder {
                            Button(action: {
                                store.send(.addFolderButtonTapped(folder))
                            }) {
                                Image(systemName: "folder.badge.plus")
                                    .imageScale(.large)
                            }
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
            }
            .sheet(item: $store.scope(state: \.addFolder, action: \.addFolder)) { store in
                AddFolderView(store: store)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    private var list: some View {
        List {
            if !store.folderTypeListCells.isEmpty {
                Section("Folders") {
                    ForEach(store.scope(state: \.folderTypeListCells, action: \.folderTypeListCell)) { store in
                        FolderTypeListCellView(store: store)
                    }
                }
            }
            
            if !store.plotListCells.isEmpty {
                Section("Memos") {
                    ForEach(store.scope(state: \.plotListCells, action: \.plotListCell)) { store in
                        PlotListCellView(store: store)
                    }
                    .onDelete { store.send(.delete($0)) }
                }
            }
        }
        .refreshable {
            store.send(.refresh)
        }
    }
}
