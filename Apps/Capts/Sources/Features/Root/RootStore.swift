import SwiftUI
import ComposableArchitecture
import PhotosUI
import UIKit

@Reducer
public struct RootStore {
    @ObservableState
    public struct State {
        public var selectedImage: UIImage?
        public var extractedText: String = ""
        public var isLoading: Bool = false
        public var selectedItems: [PhotosPickerItem] = []
        
        @Presents public var cleaned: CleanedStore.State? = nil
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case imageLoaded(UIImage)
        case textExtracted(String)
        case startCleaning
        case cleaned(PresentationAction<CleanedStore.Action>)
    }
    
    @Dependency(\.imageToTextClient) var imageToTextClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding(\.$selectedItems):
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
                
            case .cleaned:
                return .none
            }
        }
        .ifLet(\.$cleaned, action: \.cleaned) {
            CleanedStore()
        }
    }
}
