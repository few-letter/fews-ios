//
//  RootStore.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import ComposableArchitecture
import Feature_Common

public enum RootScene: Hashable {
    case home
}

@Reducer
public struct RootStore {
    @ObservableState
    public struct State {
        var path: [RootScene] = []
        
        var home: HomeStore.State = .init()
    }
    
    public enum Action {
        case onAppear
        case home(HomeStore.Action)
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
            case .home:
                return .none
            }
        }
        
        Scope(state: \.home, action: \.home) {
            HomeStore()
        }
    }
}
