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
struct mainApp: App {
    @Environment(\.modelContext) private var modelContext
    
    var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: RootStore.State()) {
                RootStore()
            } withDependencies: { dependency in
                let client = PlotClientLive(modelContext: modelContext)
                dependency.plotClient = client
            })
        }
        .modelContainer(for: Plot.self)
    }
}
