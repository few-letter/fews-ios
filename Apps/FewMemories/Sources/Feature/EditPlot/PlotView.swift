//
//  EditPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

public struct PlotView: View {
    public let store: StoreOf<PlotStore>
    
    @Environment(\.colorScheme) var colorScheme
    @State private var calendarId: UUID = UUID()
    
    public var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
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
                
                Divider()
                    .padding(.horizontal)
                
                contentView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.date) {
            calendarId = UUID()
        }
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
                    Text("\(type.rawValue)")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    private var contentView: some View {
        TextEditor(
            text: Binding(
                get: { store.plot.content ?? "" },
                set: { store.send(.contentChanged($0)) }
            )
        )
        .padding()
        .lineSpacing(5)
    }
}
