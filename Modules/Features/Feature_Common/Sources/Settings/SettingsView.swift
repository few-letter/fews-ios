//
//  SettingsView.swift
//  CommonFeature
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture
import StoreKit

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsStore>
    
    public init(store: StoreOf<SettingsStore>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: .zero) {
            Form {
                Section {
                    if store.isPremiumActive {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Ad-free activated")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            if let expirationDate = store.expirationDate {
                                Text("Expiration date: \(expirationDate, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Remaining days: \(store.remainingDays) days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {
                                store.send(.watchPremiumAd)
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Extend ad-free period")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Text("Watch another ad to refresh 7 days period")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button(action: {
                            store.send(.watchPremiumAd)
                        }) {
                            HStack {
                                Image(systemName: "play.tv")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Remove ads for 7 days")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Watch a rewarded ad to remove ads for a week")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    Text("Premium")
                }
                
                Section {
                    ForEach(GameType.allCases) { gameType in
                        Button(action: {
                            store.send(.showGame(gameType))
                        }) {
                            HStack {
                                Image(systemName: gameType.icon)
                                    .foregroundColor(gameType.color)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(gameType.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(gameType.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    Text("Games")
                }
                
                Section {
                    ForEach(OtherAppName.allCases, id: \.self) { app in
                        AppStoreLink(
                            app: app,
                            onTap: { 
                                store.send(.trackAppStoreLink(appName: app))
                                presentAppStore(appID: app.appID)
                            }
                        )
                    }
                } header: {
                    Text("Other Apps")
                }
                
                Section {
                    Link("Discord Inquiry", destination: .init(string: "https://discord.gg/BE7qTGBFcB")!)
                    Link("KakaoTalk Inquiry", destination: .init(string: "https://open.kakao.com/o/soO95nEh")!)
                } header: {
                    Text("Support")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(item: .init(
            get: { store.selectedGameType },
            set: { _ in store.send(.hideGame) }
        )) { gameType in
            switch gameType {
//            case .appleGame:
//                AppleGameView()
            case .tetris:
                TetrisGameView()
            case .twentyFortyEight:
                TwentyFortyEightGameView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    private func presentAppStore(appID: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = AppStoreDelegate.shared
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appID]
        storeViewController.loadProduct(withParameters: parameters) { result, error in
            if result {
                DispatchQueue.main.async {
                    rootViewController.present(storeViewController, animated: true)
                }
            }
        }
    }
}

struct AppStoreLink: View {
    let app: OtherAppName
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(app.logoName, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(app.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward.app")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Shared delegate for SKStoreProductViewController
class AppStoreDelegate: NSObject, SKStoreProductViewControllerDelegate {
    static let shared = AppStoreDelegate()
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true)
    }
}
