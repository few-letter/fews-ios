//
//  SettingsView.swift
//  CommonFeature
//
//  Created by 송영모 on 6/23/25.
//

import SwiftUI
import ComposableArchitecture

public struct SettingsView: View {
    public let store: StoreOf<SettingsStore>
    
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
                                        Text("Watch another ad to refresh 30 days period")
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
                                    Text("Remove ads for 30 days")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Watch a rewarded ad to remove ads for a month")
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
                    Link("Contact", destination: .init(string: "https://discord.gg/BE7qTGBFcB")!)
                } header: {
                    Text("Support")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            store.send(.onAppear)
        }
    }
}
