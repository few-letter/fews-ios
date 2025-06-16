import SwiftUI
import SwiftData
import AppTrackingTransparency
import ComposableArchitecture
import FirebaseCore
import GoogleMobileAds

public class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
public struct ToffApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let container: ModelContainer
    
    public init() {
        do {
            container = try ModelContainer(for: Ticker.self, Trade.self, Tag.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    public var body: some Scene {
        WindowGroup {
            MainTabView(store: Store(initialState: MainTabStore.State())  {
                MainTabStore()
            } withDependencies: { dependency in
                let tickerClient = TickerClientLive(context: container.mainContext)
                let tradeClient = TradeClientLive(context: container.mainContext)
                let tagClient = TagClientLive(context: container.mainContext)
                
                dependency.tickerClient = tickerClient
                dependency.tradeClient = tradeClient
                dependency.tagClient = tagClient
            })
            .environment(\.modelContext, container.mainContext)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                })
            }
        }
    }
}
