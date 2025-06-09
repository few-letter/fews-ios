import Foundation
import SwiftUI
import SwiftData
import ComposableArchitecture
import IdentifiedCollections

@Reducer
public struct DocFeature {
    @ObservableState
    public struct State {
        var docs: IdentifiedArrayOf<Doc> = []
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case onDisappear
        case refresh
        case recordsLoaded([Record])
    }
    
    public init() {}
    
    @Dependency(\.modelContext) var modelContext
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.refresh)
                
            case .onDisappear:
                return .none
                
            case .refresh:
                return .run { send in
                    let records: [Record] = (try? modelContext.fetch(.init())) ?? []
                    await send(.recordsLoaded(records))
                }
                
            case let .recordsLoaded(records):
                state.docs = []
                
                for record in records {
                    if let doc = state.docs.first(where: { Calendar.current.isDate(record.showAt ?? .now, inSameDayAs: $0.date) }) {
                        state.docs[id: doc.id]?.records.append(record)
                    } else {
                        state.docs.append(.init(records: [record], originDate: record.showAt ?? .now, date: record.showAt ?? .now))
                    }
                }
                state.docs.sort(by: { $0.date > $1.date })
                return .none
            }
        }
    }
} 