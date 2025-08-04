import AppTrackingTransparency
import ComposableArchitecture
import FirebaseCore
import GoogleMobileAds
import Mixpanel
import SwiftData
import SwiftUI

public class AppDelegate: NSObject, UIApplicationDelegate {
  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    MobileAds.shared.start()
    Mixpanel.initialize(token: .MIXPANEL_TOKEN, trackAutomaticEvents: true)
    Mixpanel.mainInstance().people.set(properties: ["app": "Multis"])
    return true
  }
}

@main
public struct MultisApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var delegate

  public init() {}

  public var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
