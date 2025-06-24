//
//  TaskCellView.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import SwiftUI

public struct TaskCellView: View {
    let task: TaskModel
    let isTimerRunning: Bool
    let onTimerToggle: () -> Void
    
    public var body: some View {
        HStack(spacing: 12) {
            // 타이머 상태 아이콘과 색상
            Circle()
                .fill(isTimerRunning ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                )
                .onTapGesture {
                    onTimerToggle()
                }
            
            VStack(alignment: .leading, spacing: 6) {
                // Task title
                Text(task.title.isEmpty ? "Untitled Task" : task.title)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    // Task time display
                    if task.time > 0 {
                        Text("\(formatTaskTime(task.time))")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(isTimerRunning ? .green : .blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(isTimerRunning ? Color.green.opacity(0.12) : Color.blue.opacity(0.12))
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
    
    private func formatTaskTime(_ milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else if seconds > 0 {
            return "\(seconds)s"
        } else {
            return "0s"
        }
    }
}
