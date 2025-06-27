//
//  AdClient.swift
//  Plots
//
//  Created by 송영모 on 6/23/25.
//

import UIKit
import GoogleMobileAds
import ComposableArchitecture
import StoreKit

// MARK: - AdClient Protocol

public protocol AdClient {
    func showOpeningAd(appID: String?) async -> Void
    func showRewardedAd(appID: String?) async throws -> Void
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
    public func showOpeningAd(appID: String?) async {
        // 프리미엄이 활성화되어 있으면 광고를 표시하지 않음
        if isPremiumActive() {
            print("Premium is active - skipping opening ad")
            return
        }
        
        guard !openingAdIsShowing else { return }
        
        // appID가 있으면 SKOverlay로 표시
        if let appID = appID {
            presentAppStoreOverlay(appID: appID, isRewarded: false)
            return
        }
        
        // 기본 Admob 광고 로직
        let adUnitID: String = .ADMOB_OPENING_AD_ID
        
        if !isOpeningAdValid(for: adUnitID) {
            await loadOpeningAd(adUnitID: adUnitID)
        }
        
        await presentOpeningAd()
    }
    
    @MainActor
    public func showRewardedAd(appID: String?) async throws {
        guard !rewardedAdIsShowing else { return }
        
        // appID가 있으면 SKOverlay로 표시하고 보상 지급
        if let appID = appID {
            presentAppStoreOverlay(appID: appID, isRewarded: true)
            return
        }
        
        // 기본 Admob 광고 로직
        let adUnitID: String = .ADMOB_REWARD_AD_ID
        
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
    
    // MARK: - Private Store Product Methods
    
    @MainActor
    private func presentAppStoreOverlay(appID: String, isRewarded: Bool) {
        guard let rootViewController = getCurrentViewController(),
              let windowScene = rootViewController.view.window?.windowScene else {
            print("❌ No window scene available")
            return
        }
        
        // 광고 상태 설정
        if isRewarded {
            rewardedAdIsShowing = true
        } else {
            openingAdIsShowing = true
        }
        
        // SKOverlay 설정
        let config = SKOverlay.AppConfiguration(appIdentifier: appID, position: .bottom)
        let overlay = SKOverlay(configuration: config)
        overlay.delegate = OverlayDelegate(
            onDismiss: { [weak self] in
                // 광고 상태 해제
                if isRewarded {
                    self?.rewardedAdIsShowing = false
                    // 리워드 광고인 경우 보상 지급
                    self?.activatePremiumByReward()
                    print("🎁 User earned reward from App ID: \(appID)")
                } else {
                    self?.openingAdIsShowing = false
                }
            }
        )
        
        // 윈도우 씬에 오버레이 표시
        overlay.present(in: windowScene)
        print("✅ Presented SKOverlay for App ID: \(appID)")
    }
    
    // Overlay Delegate for handling dismissal
    private class OverlayDelegate: NSObject, SKOverlayDelegate {
        private let onDismiss: () -> Void
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
        
        func storeOverlayDidShow(_ overlay: SKOverlay) {
            print("✅ SKOverlay did show")
        }
        
        func storeOverlayDidFailToLoad(_ overlay: SKOverlay, error: Error) {
            print("❌ SKOverlay failed to load: \(error.localizedDescription)")
            onDismiss()
        }
        
        func storeOverlayWillStartPresentation(_ overlay: SKOverlay, transitionContext: SKOverlay.TransitionContext) {
            print("SKOverlay will start presentation")
        }
        
        func storeOverlayDidFinishPresentation(_ overlay: SKOverlay, transitionContext: SKOverlay.TransitionContext) {
            print("SKOverlay did finish presentation")
        }
        
        func storeOverlayWillStartDismissal(_ overlay: SKOverlay, transitionContext: SKOverlay.TransitionContext) {
            print("SKOverlay will start dismissal")
        }
        
        func storeOverlayDidFinishDismissal(_ overlay: SKOverlay, transitionContext: SKOverlay.TransitionContext) {
            print("SKOverlay did finish dismissal")
            onDismiss()
        }
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
    
    public func showOpeningAd(appID: String?) async {
        // Test implementation - 실제 광고 대신 콘솔 출력
        if let appID = appID {
            print("🧪 Test: Showing SKOverlay with App ID: \(appID)")
        } else {
            print("🧪 Test: Showing Admob opening ad")
        }
    }
    
    public func showRewardedAd(appID: String?) async {
        // Test implementation - 실제 광고 대신 콘솔 출력
        if let appID = appID {
            print("🧪 Test: Showing SKOverlay with App ID: \(appID)")
        } else {
            print("🧪 Test: Showing Admob rewarded ad")
        }
    }
    
    public func getPremiumExpirationDate() -> Date? {
        // Test implementation - 테스트용 만료일 반환
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())
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
