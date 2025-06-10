//
//  PlotListView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

struct PlotListView: View {
    @Bindable var store: StoreOf<PlotListStore>
    
    var body: some View {
        List {
            ForEach(store.scope(state: \.filteredPlotListCells, action: \.plotListCell)) { cellStore in
                PlotListCellView(store: cellStore)
            }
            .onDelete { store.send(.delete($0)) }
        }
        .refreshable {
            store.send(.refresh)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle(store.folder.name ?? "Memories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button(action: {
                        store.send(.addButtonTapped)
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .searchable(
            text: Binding(
                get: { store.searchQuery },
                set: { store.send(.search($0)) }
            ),
            placement: .toolbar,
            prompt: "Search"
        )
    }
} 
