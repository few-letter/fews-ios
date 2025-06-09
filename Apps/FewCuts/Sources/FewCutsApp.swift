import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct FewCutsApp: App {
    var body: some Scene {
        WindowGroup {
            EditTemplateView()
//            MainTabView(
//                store: Store(initialState: MainTapStore.State()) {
//                    
//                }
//            )
        }
        .modelContainer(for: [
            
        ])
    }
}
