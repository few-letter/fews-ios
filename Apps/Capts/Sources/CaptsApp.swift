import SwiftUI
import SwiftData
import AppTrackingTransparency
import ComposableArchitecture
import FirebaseCore
import GoogleMobileAds
import Feature_Common

public class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MobileAds.shared.start()
        return true
    }
}

@main
public struct CaptsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    public init() { }

    public var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: RootStore.State())  {
                RootStore()
            } withDependencies: { dependency in
                let apiClient = APIClient()
                let imageToTextClient = ImageToTextClientLive()
                let openAIClient = OpenAIClientLive(apiClient: apiClient, apiKey: .OPENAI_API_KEY)
                let cleanedTextClient = CleanedTextClientLive(openAIClient: openAIClient)
                
                dependency.imageToTextClient = imageToTextClient
                dependency.openAIClient = openAIClient
                dependency.cleanedTextClient = cleanedTextClient
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                })
            }
        }
    }
}
