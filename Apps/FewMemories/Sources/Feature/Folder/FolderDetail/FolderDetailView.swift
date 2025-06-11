//
//  PlotListView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

public struct FolderDetailView: View {
    @Bindable var store: StoreOf<FolderDetailStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
    }
}

extension FolderDetailView {
    private var mainView: some View {
        list
            .navigationTitle(store.folderType.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .bottomBar) {
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
    }
    
    private var list: some View {
        List {
            Section("title1") {
                ForEach(store.scope(state: \.folderTypeListCells, action: \.folderTypeListCell)) { store in
                    FolderTypeListCellView(store: store)
                }
            }
            
            Section("title2") {
                ForEach(store.scope(state: \.plotListCells, action: \.plotListCell)) { store in
                    PlotListCellView(store: store)
                }
                .onDelete { store.send(.delete($0)) }
            }
        }
        .refreshable {
            store.send(.refresh)
        }
    }
}
