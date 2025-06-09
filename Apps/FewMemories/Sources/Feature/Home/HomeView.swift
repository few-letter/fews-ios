//
//  HomeView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeStore>
    
    @Environment(\.isSearching) private var isSearching
    
    public var body: some View {
        NavigationStack(path: $store.path) {
            VStack(spacing: .zero) {
                List {
                    ForEach(store.scope(state: \.filteredPlotListCells, action: \.plotListCell)) { store in
                        PlotListCellView(store: store)
                    }
                    .onDelete { store.send(.delete($0)) }
                }
                .refreshable {
                    store.send(.refresh)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action:{
                        store.send(.addButtonTapped)
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                store.send(.refresh)
            }
            .navigationTitle("Plotfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        EditButton()
                        
                        Button(action:{
                            store.send(.settingButtonTapped)
                        }) {
                            Image(systemName: "gearshape")
                                .imageScale(.medium)
                        }
                    }
                }
            }
            .navigationDestination(for: HomeScene.self) { scene in
                switch scene {
                case .editPlot:
                    if let store = store.scope(state: \.editPlot, action: \.editPlot.presented) {
                        EditPlotView(store: store)
                    }
                    
                case .setting:
                    if let store = store.scope(state: \.setting, action: \.setting.presented) {
                        SettingView(store: store)
                    }
                    
                default:
                    EmptyView()
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
}

#Preview {
    HomeView(store: Store(initialState: HomeStore.State()) {
        HomeStore()
    })
}

