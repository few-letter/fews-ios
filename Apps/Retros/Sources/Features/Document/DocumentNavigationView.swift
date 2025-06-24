//
//  DocumentNavigationView.swift
//  Retros
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI
import ComposableArchitecture

public struct DocumentNavigationView: View {
    @Bindable public var store: StoreOf<DocumentNavigationStore>
    
    public init(store: StoreOf<DocumentNavigationStore>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            contentView
                .navigationTitle("Documents")
                .refreshable {
                    store.send(.onAppear)
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .overlay {
                    AddRecordPresentationView(store: store.scope(state: \.addRecordPresentation, action: \.addRecordPresentation))
                }
        } destination: { store in
            
        }
    }
}

extension DocumentNavigationView {
    private var contentView: some View {
        VStack(spacing: 0) {
            controlsView
                .padding()
            
            recordsListView
        }
    }
    
    private var controlsView: some View {
        HStack {
            Text("Period")
                .font(.headline)
            Spacer()
            Picker("Period", selection: .init(
                get: { store.selectedPeriod },
                set: { store.send(.periodChanged($0)) }
            )) {
                ForEach(DocumentPeriod.allCases, id: \.self) { period in
                    Text(period.displayText).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var recordsListView: some View {
        List {
            if store.groupedRecords.isEmpty {
                emptyStateView
            } else {
                ForEach(sortedGroupKeys, id: \.self) { key in
                    Section(header: Text(key).font(.headline)) {
                        ForEach(store.groupedRecords[key] ?? [], id: \.id) { record in
                            RecordCellView(record: record)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    store.send(.tap(record))
                                }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Records")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("Start creating your KPT records to see them here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
    
    private var sortedGroupKeys: [String] {
        let formatter = DateFormatter()
        
        switch store.selectedPeriod {
        case .daily:
            formatter.dateFormat = "yyyy-MM-dd"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        
        return store.groupedRecords.keys.sorted { key1, key2 in
            let date1 = formatter.date(from: String(key1.prefix(10))) ?? Date.distantPast
            let date2 = formatter.date(from: String(key2.prefix(10))) ?? Date.distantPast
            return date1 > date2
        }
    }
}
