//
//  CreateFolderStore.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import Foundation
import SwiftData
import ComposableArchitecture

@Reducer
public struct AddFolderStore {
    @ObservableState
    public struct State: Equatable {
        public var folder: FolderModel
        
        public init(folder: FolderModel) {
            self.folder = folder
        }
    }
    
    public enum Action {
        case setName(String)
        
        case confirmButtonTapped
        case cancelButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case requestConfirm
            case requestCancel
        }
    }
    
    public init() {}
    
    @Dependency(\.folderClient) private var folderClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setName(let name):
                state.folder.name = name
                return .none
                
            case .confirmButtonTapped:
                folderClient.createOrUpdate(folder: state.folder)
                return .send(.delegate(.requestConfirm))
                
            case .cancelButtonTapped:
                return .send(.delegate(.requestCancel))
                
            case .delegate:
                return .none
            }
        }
    }
}
