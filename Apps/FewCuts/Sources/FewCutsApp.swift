import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct FewCutsApp: App {
    var body: some Scene {
        WindowGroup {
            AIView()
        }
        .modelContainer(for: [
            
        ])
    }
}
