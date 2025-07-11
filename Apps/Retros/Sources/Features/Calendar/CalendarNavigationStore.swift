//
//  CalendarNavigationStore.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CalendarNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var recordsByDate: [Date: IdentifiedArrayOf<RecordModel>]
        public var selectedDate: Date
        
        public var path: StackState<Path.State>
        public var addRecordPresentation: AddRecordPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            
            self.recordsByDate = [:]
            self.selectedDate = Calendar.current.startOfDay(for: .now)
            self.addRecordPresentation = .init()
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetch
        case fetched([RecordModel])
        
        case dateChanged(Date)
        case plusButtonTapped
        case tap(RecordModel)
        case delete(IndexSet)
        
        case addRecordPresentation(AddRecordPresentationStore.Action)
        case path(StackActionOf<Path>)
    }
    
    @Dependency(\.recordClient) private var recordClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .send(.fetch)
                
            case .fetch:
                let records = recordClient.fetches()
                return .send(.fetched(records))
                
            case .fetched(let records):
                state.recordsByDate = [:]
                
                let groupedByDate = Dictionary(grouping: records) { record in
                    Calendar.current.startOfDay(for: record.showAt)
                }
                
                for (date, recordsForDate) in groupedByDate {
                    let sortedRecords = recordsForDate.sorted { lhs, rhs in
                        if lhs.type.rawValue != rhs.type.rawValue {
                            return lhs.type.rawValue < rhs.type.rawValue
                        }
                        return lhs.createAt < rhs.createAt
                    }
                    
                    state.recordsByDate[date] = IdentifiedArrayOf(uniqueElements: sortedRecords)
                }
                
                return .none
                
            case .dateChanged(let date):
                state.selectedDate = date
                return .none
                
            case .plusButtonTapped:
                state.addRecordPresentation.addRecordNavigation = .init(record: .init(showAt: state.selectedDate))
                return .none
                
            case .tap(let record):
                state.addRecordPresentation.addRecordNavigation = .init(record: record)
                return .none
                
            case .delete(let indexSet):
                let selectedRecords = Array(state.recordsByDate[state.selectedDate]?.elements ?? [])
                for index in indexSet {
                    if index < selectedRecords.count {
                        let recordToDelete = selectedRecords[index]
                        recordClient.delete(recordModel: recordToDelete)
                        state.recordsByDate[state.selectedDate]?.remove(id: recordToDelete.id)
                    }
                }
                return .send(.fetch)
                
            case .addRecordPresentation(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .send(.fetch)
                }
                
            case .binding, .path, .addRecordPresentation:
                return .none
            }
        }
        
        Scope(state: \.addRecordPresentation, action: \.addRecordPresentation) {
            AddRecordPresentationStore()
        }
        .forEach(\.path, action: \.path)
    }
}
