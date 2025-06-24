//
//  S.swift
//  Toff
//
//  Created by 송영모 on 6/17/25.
//

import SwiftUI

public struct CompactSummaryCard: View {
    private let title: String
    private let value: String
    private let icon: String
    private let color: Color
    
    public init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
