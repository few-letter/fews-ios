//
//  HomeView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeStore>
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            mainView
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            switch store.case {
            case .plot(let store):
                PlotView(store: store)
            case .addPlot(let store):
                AddPlotView(store: store)
            case .setting(let store):
                SettingView(store: store)
            }
        }
        //        .sheet(isPresented: $store.folder) {
        //            newFolderSheet
        //        }
        //        .alert("폴더 삭제", isPresented: $store.isShowingDeleteAlert) {
        //            Button("취소", role: .cancel) {
        //                store.send(.dismissDeleteAlert)
        //            }
        //            Button("삭제", role: .destructive) {
        //                store.send(.deleteFolderConfirmed)
        //            }
        //        } message: {
        //            Text(store.deleteAlertMessage)
        //        }
    }
}

extension HomeView {
    private var mainView: some View {
        FolderView(store: store.scope(state: \.folder, action: \.folder))
            .sheet(
                isPresented: .init(
                    get: { store.addFolder != nil },
                    set: { _ in store.send(.dismiss) }
                )) {
                    if let store = store.scope(state: \.addFolder, action: \.addFolder) {
                        AddFolderView(store: store)
                    }
                }
        
    }
}

//extension HomeView {
//    private var mainView: some View {
//        List {
//            ForEach(store.scope(state: \.folders, action: \.folderListCell)) { store in
//                FolderListCellView(store: store)
//            }
//        }
//        .refreshable {
//            store.send(.refreshFolders)
//        }
//    }
//
//    private var newFolderSheet: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                TextField("New Folder", text: $store.newFolderName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//
//                Spacer()
//            }
//            .padding(.top)
//            .navigationTitle("New Folder")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("취소") {
//                        store.send(.newFolderSheetDismissed)
//                    }
//                }
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("완료") {
//                        store.send(.createNewFolder)
//                    }
//                    .disabled(store.newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                }
//            }
//        }
//    }
//}
