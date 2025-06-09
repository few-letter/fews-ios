import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct SettingFeature {
    @ObservableState
    public struct State {
        var safariURL: URL?
        
        public init() {}
    }
    
    public enum Action {
        case featureRequestsTapped
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .featureRequestsTapped:
                state.safariURL = URL(string: "https://tally.so/r/npKAeV")
                return .none
            }
        }
    }
} 