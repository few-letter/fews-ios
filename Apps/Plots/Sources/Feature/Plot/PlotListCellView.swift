//
//  PlotListCell.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI

public struct PlotListCellView: View {
    public let plot: PlotModel
    
    public init(plot: PlotModel) {
        self.plot = plot
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(plot.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                    
                    Text("\(plot.point, specifier: "%.1f")")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            if !plot.content.isEmpty {
                Text(plot.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            HStack {
                Text(plot.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let plotType = PlotType(rawValue: plot.type) {
                    Text(plotType.title)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
