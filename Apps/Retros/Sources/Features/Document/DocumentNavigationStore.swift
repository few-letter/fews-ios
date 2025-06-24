//
//  DocumentNavigationStore.swift
//  Retros
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import ComposableArchitecture

public enum DocumentPeriod: String, CaseIterable {
    case daily = "daily"
    case monthly = "monthly"
    case yearly = "yearly"
    
    public var displayText: String {
        switch self {
        case .daily:
            return "Daily"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

@Reducer
public struct DocumentNavigationStore {
    @Reducer
    public enum Path { }
    
    @ObservableState
    public struct State {
        public var records: [RecordModel]
        public var selectedPeriod: DocumentPeriod
        public var groupedRecords: [String: [RecordModel]]
        
        public var path: StackState<Path.State>
        public var addRecordPresentation: AddRecordPresentationStore.State
        
        public init(
            path: StackState<Path.State> = .init()
        ) {
            self.path = path
            self.records = []
            self.selectedPeriod = .daily
            self.groupedRecords = [:]
            self.addRecordPresentation = .init()
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetch
        case fetched([RecordModel])
        case periodChanged(DocumentPeriod)
        
        case tap(RecordModel)
        
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
                state.records = records.sorted { lhs, rhs in
                    if lhs.type.rawValue != rhs.type.rawValue {
                        return lhs.type.rawValue < rhs.type.rawValue
                    }
                    return lhs.createAt > rhs.createAt
                }
                return .send(.periodChanged(state.selectedPeriod))
                
            case .periodChanged(let period):
                state.selectedPeriod = period
                state.groupedRecords = groupRecordsByPeriod(records: state.records, period: period)
                return .none
                
            case .tap(let record):
                state.addRecordPresentation.addRecordNavigation = .init(record: record)
                return .none
                
            case .addRecordPresentation(.delegate(let action)):
                switch action {
                case .dismiss:
                    return .send(.fetch)
                }
                return .none
                
            case .binding, .path, .addRecordPresentation:
                return .none
            }
        }
        
        Scope(state: \.addRecordPresentation, action: \.addRecordPresentation) {
            AddRecordPresentationStore()
        }
        .forEach(\.path, action: \.path)
    }
    
    private func groupRecordsByPeriod(records: [RecordModel], period: DocumentPeriod) -> [String: [RecordModel]] {
        let formatter = DateFormatter()
        
        switch period {
        case .daily:
            formatter.dateFormat = "yyyy-MM-dd (EEEE)"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        
        let grouped = Dictionary(grouping: records) { record in
            formatter.string(from: record.showAt)
        }
        
        return grouped.mapValues { records in
            records.sorted { lhs, rhs in
                if lhs.type.rawValue != rhs.type.rawValue {
                    return lhs.type.rawValue < rhs.type.rawValue
                }
                return lhs.createAt > rhs.createAt
            }
        }
    }
}
