//
//  SettingsView.swift
//  CommonFeature
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

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
                    AppStoreLink(
                        title: "Toffs - Trading Log",
                        description: "Transform your investment data into the most intuitive 'calendar'",
                        logoName: "ToffsLogo",
                        url: "https://apps.apple.com/kr/app/toffs-%EB%A7%A4%EB%A7%A4%EC%9D%BC%EC%A7%80/id1619745259"
                    )
                    
                    AppStoreLink(
                        title: "Plots - Reading Log",
                        description: "Record what you've 'read and watched' in the simplest way",
                        logoName: "PlotsLogo",
                        url: "https://apps.apple.com/kr/app/plots-%EB%8F%85%EC%84%9C-%EA%B8%B0%EB%A1%9D/id6449458459"
                    )
                    
                    AppStoreLink(
                        title: "Retros - Reflection Diary",
                        description: "Experience continuous growth with systematic reflection",
                        logoName: "RetrosLogo",
                        url: "https://apps.apple.com/kr/app/retros-%ED%9A%8C%EA%B3%A0-%EC%9D%BC%EA%B8%B0/id6479611984"
                    )
                    
                    AppStoreLink(
                        title: "Multis - Todo Timer",
                        description: "Manage multiple tasks simultaneously with multi-timers",
                        logoName: "MultisLogo",
                        url: "https://apps.apple.com/kr/app/multis-%ED%88%AC%EB%91%90-%ED%83%80%EC%9D%B4%EB%A8%B8/id6449679061"
                    )
                    
                    AppStoreLink(
                        title: "Capts - Photo Text Extractor",
                        description: "Extract all text from photos at once with AI precision",
                        logoName: "CaptsLogo",
                        url: "https://apps.apple.com/kr/app/capts-%EC%82%AC%EC%A7%84-%ED%85%8D%EC%8A%A4%ED%8A%B8-%EB%B3%80%ED%99%98%EA%B8%B0/id6463266155"
                    )
                } header: {
                    Text("Other Apps")
                }
                
                Section {
                    Link("Contact", destination: .init(string: "https://discord.gg/BE7qTGBFcB")!)
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
//            case .tetrisGame:
//                TetrisGameView()
            case .twentyFortyEight:
                TwentyFortyEightGameView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

struct AppStoreLink: View {
    let title: String
    let description: String
    let logoName: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(logoName, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(description)
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
