//
//  FolderStore.swift
//  FewMemories
//
//  Created by 송영모 on 6/11/25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FolderStore {
    @ObservableState
    public struct State: Equatable {
        public var folderTypes: [FolderType]
        
        @Presents public var addFolder: AddFolderStore.State?
        @Presents var alert: AlertState<Action.Alert>?
        
        public init(
            folderTypes: [FolderType] = [],
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.folderTypes = folderTypes
            self.alert = alert
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case settingButtonTapped
        case addFolderButtonTapped
        case addPlotButtonTapped
        case refresh
        
        case fetch
        case fetched([Folder], [Plot])
        
        case folderTypeListCellTapped(FolderType)
        case folderTypeListCellDeleteTapped(FolderID)
        case addFolder(PresentationAction<AddFolderStore.Action>)
        case alert(PresentationAction<Alert>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case requestSetting
            case requestPlot(FolderType)
            case requestAddPlot
        }
        
        @CasePathable
        public enum Alert: Equatable {
            case requestDelete(FolderID)
        }
    }
    
    @Dependency(\.plotClient) var plotClient
    @Dependency(\.folderClient) var folderClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .send(.fetch)
                
            case .settingButtonTapped:
                return .send(.delegate(.requestSetting))
                
            case .addFolderButtonTapped:
                state.addFolder = .init(parentFolder: nil, name: "")
                return .none
                
            case .addPlotButtonTapped:
                return .send(.delegate(.requestAddPlot))
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                let folders: [Folder] = folderClient.fetchRoots()
                let plots: [Plot] = plotClient.fetches(folder: nil)
                return .send(.fetched(folders, plots))
                
            case .fetched(let folders, let plots):
                var folderTypes: [FolderType] = [.temporary(name: "All", plots: plots)]
                folderTypes += folders.map { .folder($0) }
                state.folderTypes = folderTypes
                return .none
                
            case .folderTypeListCellTapped(let folderType):
                return .send(.delegate(.requestPlot(folderType)))
                
            case .folderTypeListCellDeleteTapped(let folderID):
                guard let folderType = state.folderTypes.first(where: { $0.id == folderID }) else { return .none }
                
                state.alert = AlertState(
                    title: {
                        TextState("Delete Folder")
                    },
                    actions: {
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                        ButtonState(role: .destructive, action: .requestDelete(folderID)) {
                            TextState("Confirm")
                        }
                    },
                    message: { TextState(folderType.deleteMessage) })
                return .none
                
            case .addFolder(.presented(.delegate(let action))):
                switch action {
                case .confirm(let folder, let name):
                    let _ = folderClient.create(parentFolder: folder, name: name)
                    state.addFolder = nil
                    return .send(.fetch)
                case .dismiss:
                    state.addFolder = nil
                    return .none
                }
                
            case .alert(.presented(let action)):
                switch action {
                case .requestDelete(let folderID):
                    if case let .folder(folder) = state.folderTypes.first(where: { $0.id == folderID }) {
                        folderClient.delete(folder: folder)
                        return .send(.fetch)
                    }
                    return .none
                }
                
            case .delegate, .alert, .addFolder:
                return .none
            }
        }
        .ifLet(\.$addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
