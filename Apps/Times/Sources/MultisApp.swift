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
        Mixpanel.mainInstance().people.set(properties: [ "app":"Multis" ]) 
        return true
    }
}

@main
public struct MultisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            DyingView()
//            KanbanTimetableView()
//            MainTabView(store: Store(initialState: MainTabStore.State())  {
//                MainTabStore()
//            } withDependencies: { dependency in
//                let taskClient = TaskClientLive(context: container.mainContext)
//                let categoryClient = CategoryClientLive(context: container.mainContext)
//                
//                dependency.taskClient = taskClient
//                dependency.categoryClient = categoryClient
//            })
//            .environment(\.modelContext, container.mainContext)
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
//                })
//            }
        }
    }
}
