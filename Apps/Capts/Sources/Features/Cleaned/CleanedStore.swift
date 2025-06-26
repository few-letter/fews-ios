import Foundation
import ComposableArchitecture
import UIKit

@Reducer
public struct CleanedStore {
    @ObservableState
    public struct State {
        public var originalText: String
        public var cleanedText: String = ""
        public var isLoading: Bool = false
        
        public init(originalText: String) {
            self.originalText = originalText
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case startCleaning
        case textChunkReceived(String)
        case cleaningCompleted
        case copyText(String)
        
        case delegate(Delegate)
        public enum Delegate {
            case dismiss
        }
    }
    
    @Dependency(\.cleanedTextClient) var cleanedTextClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .send(.startCleaning)
                
            case .startCleaning:
                guard !state.originalText.isEmpty else { return .none }
                
                state.isLoading = true
                state.cleanedText = ""
                
                let request = CleaningRequest(originalText: state.originalText, option: .text)
                
                return .run { send in
                    for try await chunk in cleanedTextClient.cleanTextStream(request) {
                        await send(.textChunkReceived(chunk))
                    }
                    await send(.cleaningCompleted)
                }
                
            case .textChunkReceived(let chunk):
                state.cleanedText += chunk
                return .none
                
            case .cleaningCompleted:
                state.isLoading = false
                return .none
                
            case .copyText(let text):
                UIPasteboard.general.string = text
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

