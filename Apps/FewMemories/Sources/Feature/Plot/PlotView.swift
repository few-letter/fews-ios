//
//  PlotListView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI
import ComposableArchitecture

public struct PlotView: View {
    @Bindable var store: StoreOf<PlotStore>
    
    public var body: some View {
        mainView
            .onAppear {
                store.send(.onAppear)
            }
        
    }
}

extension PlotView {
    private var mainView: some View {
        list
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
                    }
                }
            }
    }
    
    private var list: some View {
        List {
            ForEach(store.scope(state: \.plotListCells, action: \.plotListCell)) { store in
                PlotListCellView(store: store)
            }
            .onDelete { store.send(.delete($0)) }
        }
        .refreshable {
            store.send(.refresh)
        }
    }
}
