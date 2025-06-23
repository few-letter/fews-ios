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
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("광고 제거 활성화됨")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            if let expirationDate = store.expirationDate {
                                Text("만료일: \(expirationDate, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("남은 기간: \(store.remainingDays)일")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
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
                                    Text("7일간 광고 제거하기")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("보상형 광고를 시청하고 일주일간 광고를 제거하세요")
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
                    Text("프리미엄")
                }
                
                Section {
                    Link("문의하기", destination: .init(string: "https://open.kakao.com/o/sMpFSoCh")!)
                } header: {
                    Text("지원")
                }
            }
        }
        .navigationTitle("설정")
        .onAppear {
            store.send(.onAppear)
        }
    }
}
