//
//  PlotListCell.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct PlotListCellView: View {
    let store: StoreOf<PlotListCellStore>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(store.plot.title ?? "")
                .font(.headline)
                .fontWeight(.medium)
            
            Text(store.plot.content ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            HStack(spacing: 3) {
                let stars = HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                    .frame(width: 60)
                
                stars.overlay(
                    GeometryReader { g in
                        let width = (store.plot.point ?? 0.0) / CGFloat(5) * g.size.width
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: width)
                                .foregroundColor(.yellow)
                        }
                    }
                        .mask(stars)
                )
                .foregroundColor(.gray)
                
                Text("\(store.plot.point ?? 0.0, specifier: "%.1f")")
                    .offset(.init(width: 0, height: 0.5))
                    .foregroundColor(.gray)
                    .font(.caption2)
                
                Spacer()
                
                Text(store.plot.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .fontWeight(.light)
                    .font(.caption2)
                
                Text(PlotType.toDomain(int16: store.plot.type ?? 0).rawValue)
                    .font(.caption2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.tapped)
        }
    }
}
