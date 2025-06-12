//
//  FolderListCellStore.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct FolderTypeListCellStore {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let folderType: FolderType
        
        public var id: FolderID? { return folderType.id }
        
        public init(folderType: FolderType) {
            self.folderType = folderType
        }
    }
    
    public enum Action: Equatable {
        case tapped
        case deleteButtonTapped(FolderID)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case tapped
            case requestDelete(FolderID)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .tapped:
                return .send(.delegate(.tapped))
                
            case .deleteButtonTapped(let folderID):
                return .send(.delegate(.requestDelete(folderID)))
                
            case .delegate:
                return .none
            }
        }
    }
} 
