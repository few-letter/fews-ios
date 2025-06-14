//
//  AddTickerStore.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct AddTickerStore {
    @ObservableState
    struct State: Equatable {
        var ticker: Ticker = Ticker(
            id: UUID(),
            type: .stock,
            currency: .dollar,
            name: "",
            tags: []
        )
        var availableTags: [Tag] = []
        var selectedTags: Set<Tag> = []
        
        var isFormValid: Bool {
            !ticker.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case tagToggled(Tag)
        case saveButtonTapped
        case cancelButtonTapped
        case tickerSaved
        case loadTagsResponse([Tag])
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.ticker.name):
                // 이름이 변경될 때 추가 로직이 필요하다면 여기에 작성
                return .none
                
            case .binding:
                return .none
                
            case .onAppear:
                return .run { send in
                    // Load available tags
                    // This would typically come from a repository or service
                    let tags: [Tag] = [] // Load from your data source
                    await send(.loadTagsResponse(tags))
                }
                
            case let .tagToggled(tag):
                if state.selectedTags.contains(tag) {
                    state.selectedTags.remove(tag)
                } else {
                    state.selectedTags.insert(tag)
                }
                state.ticker.tags = Array(state.selectedTags)
                return .none
                
            case .saveButtonTapped:
                guard state.isFormValid else { return .none }
                
                return .run { [ticker = state.ticker] send in
                    // Ticker 모델을 그대로 사용
                    // Save to SwiftData context
                    // This would typically be handled by a repository
                    
                    await send(.tickerSaved)
                }
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .tickerSaved:
                return .run { _ in await dismiss() }
                
            case let .loadTagsResponse(tags):
                state.availableTags = tags
                return .none
            }
        }
    }
}
