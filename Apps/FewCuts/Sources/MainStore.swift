//
//  MainStore.swift
//  FewCuts
//
//  Created by 송영모 on 6/4/25.
//

import ComposableArchitecture

public enum MainTab {
    case home
    case cuts
}

@Reducer
public struct MainTapStore {
    @ObservableState
    public struct State: Equatable {
        var home: HomeStore.State
        var cuts: CutsStore.State
        
        var currentTab: MainTab
        
        public init() {
            self.home = .init()
            self.cuts = .init()
            
            self.currentTab = .home
        }
    }
    
    public enum Action {
        case home(HomeStore.Action)
        case cuts(CutsStore.Action)
        case tab(MainTab)
    }
    
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .home:
                return .none
            case .cuts:
                return .none
            case .tab(let tab):
                state.currentTab = tab
                return .none
            }
        }
        
        Scope(state: \.home, action: \.home) {
            HomeStore()
        }
        
        Scope(state: \.cuts, action: \.cuts) {
            CutsStore()
        }
    }
}

//struct AppFeature {
//  struct State: Equatable {
//    var tab1 = CounterFeature.State()
//    var tab2 = CounterFeature.State()
//  }
//  enum Action {
//    case tab1(CounterFeature.Action)
//    case tab2(CounterFeature.Action)
//  }
//  var body: some ReducerOf<Self> {
//    Scope(state: \.tab1, action: \.tab1) {
//      CounterFeature()
//    }
//    Scope(state: \.tab2, action: \.tab2) {
//      CounterFeature()
//    }
//    Reduce { state, action in
//      // Core logic of the app feature
//      return .none
//    }
//  }
