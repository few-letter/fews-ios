//
//  Alert.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
public struct FolderDeleteAlertStore {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public let id: FolderID
        public let message: String
        
        public init(id: FolderID, message: String) {
            self.id = id
            self.message = message
        }
    }
    
    public enum Action: Equatable {
        case cancelButtonTapped
        case confirmButtonTapped
        
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case requestCancel
            case requestDelete(FolderID)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .cancelButtonTapped:
                return .send(.delegate(.requestCancel))
                
            case .confirmButtonTapped:
                return .send(.delegate(.requestDelete(state.id)))
                
            case .delegate:
                return .none
            }
        }
    }
}
