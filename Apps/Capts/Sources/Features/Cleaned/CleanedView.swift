import SwiftUI
import ComposableArchitecture

public struct CleanedView: View {
    @Bindable var store: StoreOf<CleanedStore>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<CleanedStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(store.cleanedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(store.isLoading ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                        .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text(store.isLoading ? "Cleaning..." : "Cleaning Complete")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if store.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !store.isLoading {
                            Button("Copy") {
                                store.send(.copyText(store.cleanedText))
                            }
                        }
                        
                        Button("Done") {
                            store.send(.delegate(.dismiss))
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

