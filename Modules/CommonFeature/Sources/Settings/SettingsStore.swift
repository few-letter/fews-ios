//
//  SettingsStore.swift
//  CommonFeature
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SettingsStore {
    @ObservableState
    public struct State: Equatable {
        public var isPremiumActive: Bool = false
        public var remainingDays: Int = 0
        public var expirationDate: Date?
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case watchPremiumAd
        case updatePremiumStatus
    }
    
    @Dependency(\.adClient) var adClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.updatePremiumStatus)
                
            case .watchPremiumAd:
                return .run { send in
                    await adClient.showRewardedAd(adUnitID: "ca-app-pub-3940256099942544/6978759866")
                    await send(.updatePremiumStatus)
                }
                
            case .updatePremiumStatus:
                let expirationDate = adClient.getPremiumExpirationDate()
                let isPremiumActive = expirationDate?.timeIntervalSinceNow ?? 0 > 0
                
                var remainingDays = 0
                if let expirationDate = expirationDate, isPremiumActive {
                    let components = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate)
                    remainingDays = max(0, components.day ?? 0)
                }
                
                state.isPremiumActive = isPremiumActive
                state.remainingDays = remainingDays
                state.expirationDate = expirationDate
                
                return .none
            }
        }
    }
}
