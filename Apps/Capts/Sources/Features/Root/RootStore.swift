//
//  RootStore.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import ComposableArchitecture

import Feature_Common

@Reducer
public struct RootStore {
    @ObservableState
    public struct State {
        var mainTab: MainTabStore.State = .init()
    }
    
    public enum Action {
        case onAppear
        case mainTab(MainTabStore.Action)
    }
    
    @Dependency(\.adClient) private var adClient
    @Dependency(\.analyticsClient) private var analyticsClient
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    await analyticsClient.start()
                    await adClient.showOpeningAd(appID: nil)
                }
            case .mainTab:
                return .none
            }
        }
        
        Scope(state: \.mainTab, action: \.mainTab) {
            MainTabStore()
        }
    }
}
