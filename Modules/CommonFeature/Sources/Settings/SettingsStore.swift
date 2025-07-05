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
        public var selectedGameType: GameType? = nil
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case watchPremiumAd
        case updatePremiumStatus
        case showGame(GameType)
        case hideGame
        case alert(PresentationAction<Alert>)
        
        @CasePathable
        public enum Alert: Equatable {
            case error
            case retry
        }
    }
    
    @Dependency(\.adClient) var adClient
    @Dependency(\.analyticsClient) var analyticsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(event: "settings_onAppear", properties: nil)
                return .send(.updatePremiumStatus)
                
            case .watchPremiumAd:
                analyticsClient.track(event: "watch_premium_ad_button_tapped", properties: nil)
                return .run { send in
                    try await adClient.showRewardedAd(appID: nil)
                    analyticsClient.track(event: "watch_premium_ad_success", properties: nil)
                    await send(.updatePremiumStatus)
                } catch: { error, send in
                    analyticsClient.track(event: "watch_premium_ad_failure", properties: nil)
                    await send(.alert(.presented(.error)))
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
                
            case .showGame(let gameType):
                analyticsClient.track(event: "show_game_button_tapped", properties: nil)
                state.selectedGameType = gameType
                return .none
                
            case .hideGame:
                state.selectedGameType = nil
                return .none
                
            case .alert(.presented(.error)):
                state.alert = AlertState(
                    title: { TextState("Failed to Watch Ad") },
                    actions: {
                        ButtonState(action: .send(.none)) {
                            TextState("OK")
                        }
                        ButtonState(action: .send(.retry)) {
                            TextState("Retry")
                        }
                    },
                    message: { TextState("There was a problem watching the ad.\nPlease check your network connection and try again.") }
                )
                return .none
                
            case .alert(.presented(.retry)):
                return .send(.watchPremiumAd)
                
            case .alert, .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
