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
        case alert(PresentationAction<Alert>)
        
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case requestSetting
            case requestPlot(FolderType)
            case requestAddPlot
            case requestAddFolder
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
                return .send(.delegate(.requestAddFolder))
                
            case .addPlotButtonTapped:
                return .send(.delegate(.requestAddPlot))
                
            case .refresh:
                return .send(.fetch)
                
            case .fetch:
                let folders: [Folder] = folderClient.fetches()
                let plots: [Plot] = plotClient.fetches(folder: nil)
                return .send(.fetched(folders, plots))
                
            case .fetched(let folders, let plots):
                var cells: [FolderTypeListCellStore.State] = [.init(folderType: .temporary(name: "all", plots: plots))]
                cells += folders.map { .init(folderType: .folder($0)) }
                state.folderTypeListCells = .init(uniqueElements: cells)
                return .none
                
            case .folderTypeListCell(.element(id: let id, action: .delegate(let action))):
                guard let folderType = state.folderTypeListCells[id: id]?.folderType else { return .none }
                
                switch action {
                case .tapped:
                    return .send(.delegate(.requestPlot(folderType)))
                    
                case .requestDelete(let folderID):
                    let title = "Delete Folder"
                    let message = "The \(folderType.name) folder and \(folderType.count) memos will be deleted."
                    state.alert = AlertState(
                        title: {
                            TextState(title)
                        },
                        actions: {
                            ButtonState(role: .cancel) {
                                TextState("Cancel")
                            }
                            ButtonState(role: .destructive, action: .requestDelete(folderID)) {
                                TextState("Confirm")
                            }
                        },
                        message: { TextState(message) })
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
                
            case .delegate, .folderTypeListCell, .alert:
                return .none
            }
        }
        
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.folderTypeListCells, action: \.folderTypeListCell) {
            FolderTypeListCellStore()
        }
    }
}
