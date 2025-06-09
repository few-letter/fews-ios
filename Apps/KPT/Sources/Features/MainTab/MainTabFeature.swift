import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct MainTabFeature {
    @ObservableState
    public struct State {
        var currentTab: Tab = .home
        var home: HomeFeature.State = .init()
        var doc: DocFeature.State = .init()
        var setting: SettingFeature.State = .init()
        
        public init() {}
    }
    
    public enum Action {
        case tabSelected(Tab)
        case home(HomeFeature.Action)
        case doc(DocFeature.Action)
        case setting(SettingFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Scope(state: \.doc, action: \.doc) {
            DocFeature()
        }
        
        Scope(state: \.setting, action: \.setting) {
            SettingFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.currentTab = tab
                return .none
                
            case .home, .doc, .setting:
                return .none
            }
        }
    }
}

public enum Tab: Hashable {
    case home
    case doc
    case setting
} 