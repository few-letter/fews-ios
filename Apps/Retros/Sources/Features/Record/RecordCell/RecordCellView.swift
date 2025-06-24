//
//  RecordCellView.swift
//  Retros
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI

public struct RecordCellView: View {
    let record: RecordModel
    
    public var body: some View {
        HStack(spacing: 10) {
            // 타입별 아이콘과 색상
            Circle()
                .fill(record.type.color)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: record.type.systemImageName)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // 컨텍스트 텍스트
                Text(record.context)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    // 타입 라벨
                    Text(record.type.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(record.type.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(record.type.color.opacity(0.12))
                        )
                    
                    Spacer()
                    
                    // 날짜 표시
                    Text(record.showAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
