//
//  FolderListCellStore.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FolderListCellStore {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public let folder: Folder
        public var plotCount: Int = 0
        
        public init(id: UUID = UUID(), folder: Folder, plotCount: Int = 0) {
            self.id = id
            self.folder = folder
            self.plotCount = plotCount
        }
    }
    
    public enum Action: Equatable {
        case tapped
        case deleteButtonTapped
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case tapped
            case delete
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .tapped:
                return .send(.delegate(.tapped))
                
            case .deleteButtonTapped:
                return .send(.delegate(.delete))
                
            case .delegate:
                return .none
            }
        }
    }
} 
