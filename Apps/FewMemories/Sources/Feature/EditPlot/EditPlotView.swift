//
//  EditPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct EditPlotView: View {
    public let store: StoreOf<EditPlotStore>
    
    @Environment(\.colorScheme) var colorScheme
    @State private var calendarId: UUID = UUID()
    
    public var body: some View {
        VStack(spacing: .zero) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Title", text: Binding(
                        get: { store.plot.title ?? "" },
                        set: { store.send(.titleChanged($0)) }
                    ))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 80)
                    
                    let stars = HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    var scaledX = val.location.x
                                    scaledX = scaledX < 0 ? 0.0 : scaledX
                                    scaledX = scaledX > 100 ? 100.0 : scaledX
                                    let point = round(scaledX / 100.0 * 5 * 10) / 10
                                    
                                    store.send(.pointChanged(point))
                                }
                        )
                        .frame(width: 80)
                    HStack(spacing: 5) {
                        stars.overlay(
                            GeometryReader { g in
                                let width = store.point / CGFloat(5) * g.size.width
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: width)
                                        .foregroundColor(.yellow)
                                }
                            }
                                .mask(stars)
                        )
                        .foregroundColor(.gray)
                        
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
                        .onChange(of: store.date, perform: { _ in
                            calendarId = UUID()
                        })
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    ForEach(PlotType.allCases, id: \.self) { type in
                        HStack {
                            Button(
                                action: {
                                    store.send(.typeChanged(type.int16), animation: .default)
                                },
                                label: {
                                    Image(systemName: store.type == type.int16 ? "circle.fill" : "circle")
                                        .imageScale(.small)
                                        .font(.footnote)
                                        .foregroundColor(Color(.label))
                                })
                            
                            Text("\(type.rawValue)")
                                .font(.footnote)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            
            Divider()
                .padding(.horizontal)
            
            VStack {
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct EditPlotView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditPlotView(store: .init(initialState: .init(plot: PlotCloudManager.shared.newPlot), reducer: EditPlotStore()._printChanges()))
//    }
//}
