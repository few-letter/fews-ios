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
        public var folderTypeListCells: IdentifiedArrayOf<FolderTypeListCellStore.State>
        
        @Presents public var addFolder: AddFolderStore.State?
        @Presents var alert: AlertState<Action.Alert>?
        
        public init(
            folderTypeListCells: IdentifiedArrayOf<FolderTypeListCellStore.State> = [],
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.folderTypeListCells = folderTypeListCells
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
        
        case folderTypeListCell(IdentifiedActionOf<FolderTypeListCellStore>)
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
                var cells: [FolderTypeListCellStore.State] = [.init(folderType: .temporary(name: "All", plots: plots))]
                cells += folders.map { .init(folderType: .folder($0)) }
                state.folderTypeListCells = .init(uniqueElements: cells)
                return .none
                
            case .folderTypeListCell(.element(id: let id, action: .delegate(let action))):
                guard let folderType = state.folderTypeListCells[id: id]?.folderType else { return .none }
                
                switch action {
                case .tapped:
                    return .send(.delegate(.requestPlot(folderType)))
                    
                case .requestDelete(let folderID):
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
                }
                
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
                    if case let .folder(folder) = state.folderTypeListCells[id: folderID]?.folderType {
                        folderClient.delete(folder: folder)
                        return .send(.fetch)
                    }
                    return .none
                }
                
            case .delegate, .folderTypeListCell, .alert, .addFolder:
                return .none
            }
        }
        .ifLet(\.$addFolder, action: \.addFolder) {
            AddFolderStore()
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.folderTypeListCells, action: \.folderTypeListCell) {
            FolderTypeListCellStore()
        }
    }
}
