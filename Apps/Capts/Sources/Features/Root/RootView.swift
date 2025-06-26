import SwiftUI
import ComposableArchitecture
import PhotosUI

public struct RootView: View {
    @Bindable var store: StoreOf<RootStore>
    
    public init(store: StoreOf<RootStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let selectedImage = store.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                if !store.extractedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Extracted Text")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            Text(store.extractedText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .textSelection(.enabled)
                        }
                        .frame(maxHeight: 400)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    PhotosPicker(
                        selection: $store.selectedItems,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        Label("Select Image", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button("Clean with AI") {
                        store.send(.startCleaning)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(store.extractedText.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(store.extractedText.isEmpty || store.isLoading)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Capts")
            .sheet(item: $store.scope(state: \.cleaned, action: \.cleaned)) { store in
                CleanedView(store: store)
            }
        }
    }
}


