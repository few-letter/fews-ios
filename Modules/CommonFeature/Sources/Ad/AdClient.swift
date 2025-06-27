//
//  AdClient.swift
//  Plots
//
//  Created by 송영모 on 6/23/25.
//

import UIKit
import GoogleMobileAds
import ComposableArchitecture

// MARK: - AdClient Protocol

public protocol AdClient {
    func showOpeningAd(customAdUnitID: String?) async -> Void
    func showRewardedAd(customAdUnitID: String?) async throws -> Void
    func getPremiumExpirationDate() -> Date?
}

// MARK: - Live Implementation

public class AdClientLive: NSObject, AdClient {
    // Opening Ad Management
    private var appOpenAd: AppOpenAd?
    private var openingAdIsLoading = false
    private var openingAdIsShowing = false
    private var openingAdLoadTime: Date?
    private var currentOpeningAdUnitID: String?
    private let openingAdExpirationTime: TimeInterval = 14400 // 4 hours
    
    // Rewarded Ad Management (변경됨)
    private var rewardedAd: RewardedAd?
    private var rewardedAdIsLoading = false
    private var rewardedAdIsShowing = false
    
    // Premium Management
    private let userDefaults: UserDefaults
    
    private enum Keys {
        static let premiumExpirationDate = "premiumExpirationDate"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        super.init()
        
        let _ = print("ADMOB_REWARD_AD_ID", String.ADMOB_REWARD_AD_ID)
        let _ = print("ADMOB_OPENING_AD_ID", String.ADMOB_OPENING_AD_ID)
    }
    
    // MARK: - Public Methods
    
    @MainActor
    public func showOpeningAd(customAdUnitID: String?) async {
        // 프리미엄이 활성화되어 있으면 광고를 표시하지 않음
        if isPremiumActive() {
            print("Premium is active - skipping opening ad")
            return
        }
        
        guard !openingAdIsShowing else { return }
        
        let adUnitID: String = customAdUnitID ?? .ADMOB_OPENING_AD_ID
        
        if !isOpeningAdValid(for: adUnitID) {
            await loadOpeningAd(adUnitID: adUnitID)
        }
        
        await presentOpeningAd()
    }
    
    @MainActor
    public func showRewardedAd(customAdUnitID: String?) async throws {
        guard !rewardedAdIsShowing else { return }
        
        let adUnitID: String = customAdUnitID ?? .ADMOB_REWARD_AD_ID
        
        try await loadRewardedAd(adUnitID: adUnitID)
        await presentRewardedAd()
    }
    
    public func getPremiumExpirationDate() -> Date? {
        return userDefaults.object(forKey: Keys.premiumExpirationDate) as? Date
    }
    
    // MARK: - Private Opening Ad Methods
    
    private func loadOpeningAd(adUnitID: String) async {
        guard !openingAdIsLoading,
              !isOpeningAdValid(for: adUnitID) else { return }
        
        openingAdIsLoading = true
        
        do {
            appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            appOpenAd?.fullScreenContentDelegate = self
            openingAdLoadTime = Date()
            currentOpeningAdUnitID = adUnitID
        } catch {
            print("Failed to load opening ad: \(error.localizedDescription)")
        }
        
        openingAdIsLoading = false
    }
    
    @MainActor
    private func presentOpeningAd() async {
        guard let ad = appOpenAd,
              let rootViewController = getCurrentViewController() else { return }
        
        openingAdIsShowing = true
        ad.present(from: rootViewController)
    }
    
    private func isOpeningAdValid(for adUnitID: String) -> Bool {
        guard
            let _ = appOpenAd,
            let loadTime = openingAdLoadTime,
            currentOpeningAdUnitID == adUnitID
        else {
            return false
        }
        
        return Date().timeIntervalSince(loadTime) < openingAdExpirationTime
    }
    
    private func resetOpeningAd() {
        appOpenAd = nil
        openingAdIsShowing = false
        currentOpeningAdUnitID = nil
    }
    
    // MARK: - Private Rewarded Ad Methods (수정됨)
    
    private func loadRewardedAd(adUnitID: String) async throws {
        guard !rewardedAdIsLoading else { return }
        rewardedAdIsLoading = true
        rewardedAd = try await RewardedAd.load(
            with: adUnitID,
            request: Request()
        )
        rewardedAd?.fullScreenContentDelegate = self
        rewardedAdIsLoading = false
    }
    
    @MainActor
    private func presentRewardedAd() async {
        guard let ad = rewardedAd,
              let rootViewController = getCurrentViewController() else { return }
        
        rewardedAdIsShowing = true
        
        // present 메서드 사용법 변경
        ad.present(from: rootViewController) { [weak self] in
            // 보상 정보 가져오기
            let reward = ad.adReward
            print("🎁 User earned reward: \(reward.amount) \(reward.type)")
            
            // 보상 처리 - 프리미엄 활성화
            self?.activatePremiumByReward()
        }
    }
    
    private func resetRewardedAd() {
        rewardedAd = nil
        rewardedAdIsShowing = false
    }
    
    // MARK: - Premium Management
    
    private func activatePremiumByReward() {
        let expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        userDefaults.set(expirationDate, forKey: Keys.premiumExpirationDate)
    }
    
    private func isPremiumActive() -> Bool {
        guard let expirationDate = userDefaults.object(forKey: Keys.premiumExpirationDate) as? Date else {
            return false
        }
        return Date() < expirationDate
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: \.isKeyWindow) else {
            return nil
        }
        
        var current = window.rootViewController
        
        while let presented = current?.presentedViewController {
            current = presented
        }
        
        if let nav = current as? UINavigationController {
            current = nav.visibleViewController
        }
        
        if let tab = current as? UITabBarController {
            current = tab.selectedViewController
        }
        
        return current
    }
}

// MARK: - FullScreenContentDelegate

extension AdClientLive: FullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present full screen content")
    }
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad did dismiss full screen content")
        
        if ad is AppOpenAd {
            resetOpeningAd()
        } else if ad is RewardedAd {  // RewardedInterstitialAd → RewardedAd로 변경
            resetRewardedAd()
        }
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        
        if ad is AppOpenAd {
            resetOpeningAd()
        } else if ad is RewardedAd {  // RewardedInterstitialAd → RewardedAd로 변경
            resetRewardedAd()
        }
    }
}

// MARK: - Test Implementation

public class AdClientTest: AdClient {
    public init() {}
    
    public func showOpeningAd(customAdUnitID: String?) async {
        fatalError()
    }
    
    public func showRewardedAd(customAdUnitID: String?) async {
        fatalError()
    }
    
    public func getPremiumExpirationDate() -> Date? {
        fatalError()
    }
}

// MARK: - Dependency

private struct AdClientKey: DependencyKey {
    static let liveValue: any AdClient = AdClientLive()
    static let testValue: any AdClient = AdClientTest()
}

extension DependencyValues {
    public var adClient: any AdClient {
        get { self[AdClientKey.self] }
        set { self[AdClientKey.self] = newValue }
    }
}
