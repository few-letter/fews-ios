//
//  EditPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

//
//  EditPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

//
//  EditPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

public struct AddPlotView: View {
    public let store: StoreOf<AddPlotStore>
    
    @Environment(\.colorScheme) var colorScheme
    @State private var calendarId: UUID = UUID()
    @State private var isScrolled: Bool = false
    
    public var body: some View {
        ZStack(alignment: .top) {
            // 메인 스크롤 컨텐츠
            ScrollView {
                VStack(spacing: .zero) {
                    // 투명한 스티키 헤더 높이 확보용
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: isScrolled ? 60 : 0)
                        .animation(.easeInOut(duration: 0.2), value: isScrolled)
                    
                    // 전체 헤더 영역
                    fullHeaderView
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // 초기 스크롤 상태 설정
                                    }
                                    .onChange(of: geometry.frame(in: .global).minY) { offset in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isScrolled = offset < -50
                                        }
                                    }
                            }
                        )
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // TextEditor 영역
                    textEditorView
                }
            }
            .coordinateSpace(name: "scroll")
            
            // 스티키 헤더
            if isScrolled {
                stickyHeaderView
                    .background(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.date) {
            calendarId = UUID()
        }
    }
    
    private var fullHeaderView: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 10) {
                titleView
                Spacer()
                plotControlsView
            }
            Spacer()
            plotTypeView
        }
        .padding()
    }
    
    private var stickyHeaderView: some View {
        HStack {
            // 제목 (축약)
            Text(store.plot.title?.isEmpty == false ? store.plot.title! : "Title")
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(store.plot.title?.isEmpty == false ? .primary : .secondary)
            
            Spacer()
            
            // 별점
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text("\(store.point, specifier: "%.1f")")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            // 타입
            if let plotType = PlotType.allCases.first(where: { $0.rawValue == store.type }) {
                Text(plotType.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var titleView: some View {
        TextField(
            "Title",
            text: Binding(
                get: { store.plot.title ?? "" },
                set: { store.send(.titleChanged($0)) }
            )
        )
        .font(.title3)
        .fontWeight(.semibold)
        .padding(.bottom, 20)
    }
    
    private var plotControlsView: some View {
        HStack(spacing: 10) {
            starRatingView(point: store.point, onPointChanged: { store.send(.pointChanged($0)) })
            Text("\(store.point, specifier: "%.1f")")
                .font(.subheadline)
                .fontWeight(.semibold)
            Button(action: {
                store.send(.pointChanged(0), animation: .default)
            }, label: {
                Image(systemName: "arrow.counterclockwise")
                    .imageScale(.small)
                    .foregroundColor(Color(.label))
            })
            DatePicker(
                "",
                selection: Binding(
                    get: { store.date },
                    set: { store.send(.dateChanged($0)) }
                ),
                displayedComponents: [.date]
            )
            .id(calendarId)
        }
    }
    
    private func starRatingView(point: Double, onPointChanged: @escaping (Double) -> Void) -> some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        return stars
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { val in
                        var scaledX = val.location.x
                        scaledX = scaledX < 0 ? 0.0 : scaledX
                        scaledX = scaledX > 100 ? 100.0 : scaledX
                        let newPoint = round(scaledX / 100.0 * 5 * 10) / 10
                        onPointChanged(newPoint)
                    }
            )
            .frame(width: 80)
            .overlay(
                GeometryReader { g in
                    let width = point / 5.0 * g.size.width
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: width)
                            .foregroundColor(.yellow)
                    }
                }
                .mask(stars)
            )
            .foregroundColor(.gray)
    }
    
    private var plotTypeView: some View {
        VStack(alignment: .leading) {
            ForEach(PlotType.allCases, id: \.self) { type in
                HStack {
                    Button(
                        action: {
                            store.send(.typeChanged(type.rawValue), animation: .default)
                        },
                        label: {
                            Image(systemName: store.type == type.rawValue ? "circle.fill" : "circle")
                                .imageScale(.small)
                                .font(.footnote)
                                .foregroundColor(Color(.label))
                        }
                    )
                    Text("\(type.title)")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    private var textEditorView: some View {
        ExpandingTextEditor(
            text: Binding(
                get: { store.plot.content ?? "" },
                set: { store.send(.contentChanged($0)) }
            )
        )
        .padding()
    }
}

// 확장 가능한 TextEditor 구현
struct ExpandingTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false // 스크롤 비활성화
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: ExpandingTextEditor
        
        init(_ parent: ExpandingTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 텍스트가 변경될 때마다 크기 재계산
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
        }
    }
}

