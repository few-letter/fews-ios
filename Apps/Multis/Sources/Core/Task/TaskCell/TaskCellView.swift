//
//  TaskCellView.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI

public struct TaskCellView: View {
    let task: TaskData
    let isTimerRunning: Bool
    let onTimerToggle: () -> Void
    
    public var body: some View {
        HStack(spacing: 12) {
            // 카테고리 색상과 타이머 상태
            ZStack {
                // 배경 원
                Circle()
                    .fill(isTimerRunning ? Color.white : categoryColor)
                    .frame(width: 32, height: 32)
                
                // 타이머 실행 중일 때 테두리
                if isTimerRunning {
                    Circle()
                        .stroke(categoryColor, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
                
                // 타이머 아이콘
                Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                    .foregroundColor(isTimerRunning ? categoryColor : .white)
                    .font(.system(size: 14, weight: .medium))
            }
            .onTapGesture {
                onTimerToggle()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Task title과 카테고리
                HStack {
                    Text(task.title.isEmpty ? "Untitled Task" : task.title)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // 카테고리 표시
                    if let category = task.category {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: category.color) ?? .gray)
                                .frame(width: 8, height: 8)
                            
                            Text(category.title)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack {
                    // Task time display
                    if task.time > 0 {
                        Text("\(formatTaskTime(task.time))")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(timeTagColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(timeTagColor.opacity(0.12))
                            )
                    }
                    
                    Spacer()
                    
                    // Date display
                    Text(task.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var categoryColor: Color {
        if let category = task.category {
            return Color(hex: category.color) ?? .gray
        }
        return .gray.opacity(0.3)
    }
    
    private var timeTagColor: Color {
        if isTimerRunning {
            return .green
        } else if let category = task.category {
            return Color(hex: category.color) ?? .blue
        } else {
            return .blue
        }
    }
    
    private func formatTaskTime(_ milliseconds: Int) -> String {
        let totalMs = milliseconds
        let hours = totalMs / (1000 * 60 * 60)
        let minutes = (totalMs % (1000 * 60 * 60)) / (1000 * 60)
        let seconds = (totalMs % (1000 * 60)) / 1000
        let ms = (totalMs % 1000) / 10 // 10ms 단위로 2자리 표시
        
        return String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, ms)
    }
}
