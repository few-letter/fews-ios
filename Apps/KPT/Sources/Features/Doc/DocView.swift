import SwiftUI
import ComposableArchitecture
import DS

public struct DocView: View {
    let store: StoreOf<DocFeature>
    
    public init(store: StoreOf<DocFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 0) {
                    // 헤더 섹션
                    DSCard(cardShadow: .sm) {
                        DSCardBody {
                            HStack {
                                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                    Text("Documentation")
                                        .font(DS.Typography.h3)
                                        .foregroundColor(DS.Colors.content1)
                                    
                                    Text("Your KPT reflection history")
                                        .font(DS.Typography.bodyRegular)
                                        .foregroundColor(DS.Colors.content2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(DS.Colors.primary)
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.top, DS.Spacing.sm)
                    
                    // 문서 리스트
                    if store.docs.isEmpty {
                        emptyStateView
                    } else {
                        documentListView
                    }
                }
                .background(DS.Colors.background)
                .navigationBarHidden(true)
            }
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
        }
    }
}

private extension DocView {
    var emptyStateView: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()
            
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(DS.Colors.content3)
            
            VStack(spacing: DS.Spacing.sm) {
                Text("No Documents Yet")
                    .font(DS.Typography.h4)
                    .foregroundColor(DS.Colors.content1)
                
                Text("Start reflecting on your experiences\nto create your first KPT document")
                    .font(DS.Typography.bodyRegular)
                    .foregroundColor(DS.Colors.content2)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.md)
    }
    
    var documentListView: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(store.docs) { doc in
                    documentCard(for: doc)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.top, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xl)
        }
        .refreshable {
            store.send(.refresh)
        }
    }
    
    func documentCard(for doc: Doc) -> some View {
        DSCard(cardShadow: .sm, isHoverable: true) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                // 날짜 헤더
                DSCardHeader {
                    HStack {
                        Text(doc.date.formatted(date: .abbreviated, time: .omitted))
                            .font(DS.Typography.h5)
                            .foregroundColor(DS.Colors.content1)
                        
                        Spacer()
                        
                        Text("\(doc.records.count) items")
                            .font(DS.Typography.smallMedium)
                            .foregroundColor(DS.Colors.content3)
                            .padding(.horizontal, DS.Spacing.sm)
                            .padding(.vertical, DS.Spacing.xs)
                            .background(DS.Colors.surface)
                            .clipShape(Capsule())
                    }
                }
                
                DSCardBody {
                    VStack(spacing: DS.Spacing.md) {
                        // KEEP 아이템들
                        if !doc.keeps.isEmpty {
                            recordSection(
                                title: "KEEP",
                                records: doc.keeps,
                                color: DS.Colors.Green._500,
                                backgroundColor: DS.Colors.Green._100
                            )
                        }
                        
                        // PROBLEM 아이템들
                        if !doc.problems.isEmpty {
                            recordSection(
                                title: "PROBLEM",
                                records: doc.problems,
                                color: DS.Colors.Orange._500,
                                backgroundColor: DS.Colors.Orange._100
                            )
                        }
                        
                        // TRY 아이템들
                        if !doc.tries.isEmpty {
                            recordSection(
                                title: "TRY",
                                records: doc.tries,
                                color: DS.Colors.Blue._500,
                                backgroundColor: DS.Colors.Blue._100
                            )
                        }
                    }
                }
            }
        }
    }
    
    func recordSection(
        title: String,
        records: [Record],
        color: Color,
        backgroundColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text(title)
                    .font(DS.Typography.smallMedium)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(records.count)")
                    .font(DS.Typography.smallMedium)
                    .foregroundColor(color)
                    .padding(.horizontal, DS.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(backgroundColor)
                    .clipShape(Capsule())
            }
            
            VStack(spacing: DS.Spacing.xs) {
                ForEach(records.prefix(3), id: \.persistentModelID) { record in
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                        
                        Text(record.context ?? "")
                            .font(DS.Typography.bodyRegular)
                            .foregroundColor(DS.Colors.content1)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                
                if records.count > 3 {
                    HStack {
                        Circle()
                            .fill(DS.Colors.content3)
                            .frame(width: 4, height: 4)
                        
                        Text("그리고 \(records.count - 3)개 더...")
                            .font(DS.Typography.smallRegular)
                            .foregroundColor(DS.Colors.content3)
                        
                        Spacer()
                    }
                }
            }
        }
    }
} 