//
//  plotfolioApp.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/20.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct FewMemoriesApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Plot.self, Folder.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: RootStore.State()) {
                RootStore()
            } withDependencies: { dependency in
                let plotClient = PlotClientLive(context: container.mainContext)
                let folderClient = FolderClientLive(context: container.mainContext)
                dependency.plotClient = plotClient
                dependency.folderClient = folderClient
            })
            .environment(\.modelContext, container.mainContext)
        }
    }
}
