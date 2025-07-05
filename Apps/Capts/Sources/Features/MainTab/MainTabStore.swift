//
//  MainTabStore.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import UIKit

import Feature_Common

@Reducer
public struct MainTabStore {
    @Reducer
    public enum Path {
        case settings(SettingsStore)
    }
    
    @ObservableState
    public struct State {
        public var selectedImage: UIImage?
        public var extractedText: String = ""
        public var isLoading: Bool = false
        public var selectedItems: [PhotosPickerItem] = []
        
        public var path: StackState<Path.State> = .init()
        @Presents public var cleaned: CleanedStore.State? = nil
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case settingButtonTapped
        
        case imageLoaded(UIImage)
        case textExtracted(String)
        case startCleaning
        
        case path(StackActionOf<Path>)
        case cleaned(PresentationAction<CleanedStore.Action>)
    }
    
    @Dependency(\.imageToTextClient) var imageToTextClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding(\.selectedItems):
                guard let firstItem = state.selectedItems.first else { return .none }
                
                state.extractedText = ""
                state.isLoading = true
                
                return .run { send in
                    if let data = try? await firstItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await send(.imageLoaded(image))
                    }
                }
                
            case .binding:
                return .none
                
            case .onAppear:
                return .none
                
            case .settingButtonTapped:
                state.path.append(.settings(.init()))
                return .none
                
                
            case .imageLoaded(let image):
                state.selectedImage = image
                
                return .run { send in
                    if let text = try? await imageToTextClient.extractText(from: image) {
                        await send(.textExtracted(text))
                    }
                }
                
            case .textExtracted(let text):
                state.extractedText = text
                state.isLoading = false
                return .none
                
            case .startCleaning:
                guard !state.extractedText.isEmpty else { return .none }
                
                state.cleaned = CleanedStore.State(originalText: state.extractedText)
                return .none
                
            case .cleaned(.presented(.delegate(.dismiss))):
                state.cleaned = nil
                return .none
                
            case .cleaned, .path:
                return .none
            }
        }
        .ifLet(\.$cleaned, action: \.cleaned) {
            CleanedStore()
        }
        .forEach(\.path, action: \.path)
    }
}
