import SwiftUI
import ComposableArchitecture
import UIKit

public struct AppView: View {
    let store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        MainTabView(store: store.scope(state: \.mainTab, action: \.mainTab))
            .onAppear {
                store.send(.appDelegate(.didFinishLaunching))
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                store.send(.appDelegate(.didBecomeActive))
            }
    }
} 