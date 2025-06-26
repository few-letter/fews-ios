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
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(store.isLoading ? "Cleaning..." : "Cleaning Complete")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if store.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Spacer()
                    
                    if !store.isLoading {
                        Button("Copy") {
                            store.send(.copyText(store.cleanedText))
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    Text(store.cleanedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(store.isLoading ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.send(.delegate(.dismiss))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

