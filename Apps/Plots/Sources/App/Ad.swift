//
//  Ad.swift
//  Plots
//
//  Created by 송영모 on 6/14/25.
//

import UIKit
import GoogleMobileAds

class AppOpenAdManager: NSObject {
    private var appOpenAd: AppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?
    private let fourHoursInSeconds = TimeInterval(14400)
    private var adUnitID: String = Bundle.main.infoDictionary?["ADMOB_OPENING_AD_ID"] as? String ?? ""
    
    static let shared = AppOpenAdManager()
    private override init() { super.init() }
    
    func configure(with adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    @MainActor
    func showAdIfAvailable() async {
        guard !isShowingAd else { return }
        
        if !isAdAvailable() {
            await loadAd()
        }
        
        if let ad = appOpenAd, let rootViewController = getCurrentViewController() {
            isShowingAd = true
            ad.present(from: rootViewController)
        }
    }
    
    func preloadAd() {
        Task { await loadAd() }
    }
    
    private func loadAd() async {
        if isLoadingAd || isAdAvailable() { return }
        
        isLoadingAd = true
        
        do {
            appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            appOpenAd?.fullScreenContentDelegate = self
            loadTime = Date()
        } catch { }
        
        isLoadingAd = false
    }
    
    private func wasLoadTimeLessThanFourHoursAgo() -> Bool {
        guard let loadTime = loadTime else { return false }
        return Date().timeIntervalSince(loadTime) < fourHoursInSeconds
    }
    
    private func isAdAvailable() -> Bool {
        return appOpenAd != nil && wasLoadTimeLessThanFourHoursAgo()
    }
    
    @MainActor
    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var currentViewController = window.rootViewController
        
        while let presentedViewController = currentViewController?.presentedViewController {
            currentViewController = presentedViewController
        }
        
        if let navigationController = currentViewController as? UINavigationController {
            currentViewController = navigationController.visibleViewController
        }
        
        if let tabBarController = currentViewController as? UITabBarController {
            currentViewController = tabBarController.selectedViewController
        }
        
        return currentViewController
    }
}

extension AppOpenAdManager: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) { }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
        isShowingAd = false
        Task { await loadAd() }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        appOpenAd = nil
        isShowingAd = false
        Task { await loadAd() }
    }
}
