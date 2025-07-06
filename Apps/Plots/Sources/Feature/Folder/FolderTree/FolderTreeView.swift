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
            if !store.folderTypes.isEmpty {
                Section("Folders") {
                    ForEach(store.folderTypes, id: \.id) { folderType in
                        Button(action: {
                            store.send(.folderTypeListCellTapped(folderType))
                        }) {
                            FolderTypeListCellView(folderType: folderType)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            if let folder = folderType.folder {
                                Button(role: .destructive, action: {
                                    store.send(.folderTypeListCellDeleteTapped(folder.id))
                                }) {
                                    Label("Delete Folder", systemImage: "trash")
                                }
                                Button {
                                    store.send(.editFolderButtonTapped(folder))
                                } label: {
                                    Label("Edit Folder", systemImage: "pencil")
                                }
                            }
                        }
                    }
                }
            }
            
            if !store.plots.isEmpty {
                Section("Memos") {
                    ForEach(store.plots, id: \.id) { plot in
                        Button(action: {
                            store.send(.plotListCellTapped(plot))
                        }) {
                            PlotListCellView(plot: plot)
                        }
                        .buttonStyle(PlainButtonStyle())
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
