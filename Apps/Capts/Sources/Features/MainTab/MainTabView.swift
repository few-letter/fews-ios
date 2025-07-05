//
//  MainTabView.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

import Feature_Common

public struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabStore>
    
    public init(store: StoreOf<MainTabStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
                .navigationTitle("Capts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            store.send(.settingButtonTapped)
                        }) {
                            Image(systemName: "gearshape")
                                .imageScale(.medium)
                        }
                    }
                }
                .sheet(item: $store.scope(state: \.cleaned, action: \.cleaned)) { store in
                    CleanedView(store: store)
                }
        } destination: { store in
            switch store.case {
            case .settings(let store):
                SettingsView(store: store)
            }
        }
    }
}

extension MainTabView {
    private var mainView: some View {
        ZStack {
            ScrollView {
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
                            HStack {
                                Text("Extracted Text")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Copy") {
                                    UIPasteboard.general.string = store.extractedText
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            
                            Text(store.extractedText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .textSelection(.enabled)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 120)
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
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
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}


