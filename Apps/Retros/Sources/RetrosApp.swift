import SwiftUI
import SwiftData
import AppTrackingTransparency
import ComposableArchitecture
import FirebaseCore
import GoogleMobileAds
import Mixpanel

public class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MobileAds.shared.start()
        Mixpanel.initialize(token: .MIXPANEL_TOKEN, trackAutomaticEvents: true)
        Mixpanel.mainInstance().people.set(properties: [ "app":"Retros" ])
        return true
    }
}

@main
public struct RetrosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let container: ModelContainer
    
    public init() {
        do {
            container = try ModelContainer(for: Record.self)
            container.mainContext.autosaveEnabled = false
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    public var body: some Scene {
        WindowGroup {
            MainTabView(store: Store(initialState: MainTabStore.State())  {
                MainTabStore()
            } withDependencies: { dependency in
                let recordClient = RecordClientLive(context: container.mainContext)
                
                dependency.recordClient = recordClient
            })
            .environment(\.modelContext, container.mainContext)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                })
            }
        }
    }
}
