//
//  MixpanelClient.swift
//  CommonFeature
//
//  Created by 송영모 on 6/27/25.
//

import Foundation
import Mixpanel
import ComposableArchitecture

// MARK: - MixpanelClient Protocol

public protocol AnalyticsClient {
    func start() async -> Void
    func track(event: String, properties: Properties?) -> Void
}

// MARK: - Live Implementation

public class MixpanelClientLive: AnalyticsClient {
    private let userDefaults: UserDefaults
    
    private enum Keys {
        static let userUUID = "mixpanel_user_uuid"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func start() async {
        Mixpanel.initialize(token: .MIXPANEL_TOKEN, trackAutomaticEvents: true)
        
        let userUUID = getUserUUID()
        
        Mixpanel.mainInstance().identify(distinctId: userUUID)
        
        let userProperties: Properties = [
            "uuid": userUUID,
            "platform": "iOS",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "app_name": Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "unknown"
        ]
        
        Mixpanel.mainInstance().people.set(properties: userProperties)
    }
    
    public func track(event: String, properties: Properties? = nil) {
        var trackingProperties: Properties = [
            "timestamp": Date().iso8601String,
            "platform": "iOS"
        ]
        
        if let properties = properties {
            trackingProperties.merge(properties) { _, new in new }
        }
        
        Mixpanel.mainInstance().track(event: event, properties: trackingProperties)
        print("📊 Mixpanel tracked event: \(event) with properties: \(trackingProperties)")
    }
    
    // MARK: - Private Methods
    
    private func getUserUUID() -> String {
        if let existingUUID = userDefaults.string(forKey: Keys.userUUID) {
            return existingUUID
        }
        
        let newUUID = UUID().uuidString
        userDefaults.set(newUUID, forKey: Keys.userUUID)
        return newUUID
    }
}

// MARK: - Test Implementation

public class MixpanelClientTest: AnalyticsClient {
    public init() {}
    
    public func start() async {
        print("🧪 Test: MixpanelClient initUser called")
    }
    
    public func track(event: String, properties: Properties?) {
        print("🧪 Test: MixpanelClient track called with event: \(event), properties: \(properties ?? [:])")
    }
}

// MARK: - Dependency

private struct AnalyticsClientKey: DependencyKey {
    static let liveValue: any AnalyticsClient = MixpanelClientLive()
    static let testValue: any AnalyticsClient = MixpanelClientTest()
}

extension DependencyValues {
    public var analyticsClient: any AnalyticsClient {
        get { self[AnalyticsClientKey.self] }
        set { self[AnalyticsClientKey.self] = newValue }
    }
}

// MARK: - Helper Extensions

private extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
