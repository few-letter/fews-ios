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
            ForEach(store.scope(state: \.plotListCells, action: \.plotListCell)) { store in
                PlotListCellView(store: store)
            }
            .onDelete { store.send(.delete($0)) }
        }
        .refreshable {
            store.send(.refresh)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle(store.folderType.name)
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
    }
} 
