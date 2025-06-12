//
//  plotfolioApp.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/20.
//

import SwiftUI
import SwiftData
import AppTrackingTransparency
import ComposableArchitecture
import FirebaseCore

@main
struct PlotsApp: App {
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
            ContentView()
        }
    }
}
