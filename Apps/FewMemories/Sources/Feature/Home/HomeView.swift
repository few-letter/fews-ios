//
//  HomeView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeStore>
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            switch store.case {
            case .folderTree(let store):
                FolderTreeView(store: store)
            case .addPlot(let store):
                AddPlotView(store: store)
            case .setting(let store):
                SettingView(store: store)
            }
        }
    }
}

extension HomeView {
    private var mainView: some View {
        FolderView(store: store.scope(state: \.folder, action: \.folder))
    }
}
