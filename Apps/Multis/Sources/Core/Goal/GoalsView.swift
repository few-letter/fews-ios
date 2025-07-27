//
//  GoalsView.swift
//  Multis
//
//  Created by 송영모 on 7/27/25.
//

import SwiftUI
import Feature_Common

public struct GoalsView: View {
    private var goals: [GoalItem]
    private var select: (GoalItem) -> Void
    
    public init(goals: [GoalItem], select: @escaping (GoalItem) -> Void) {
        self.goals = goals
        self.select = select
    }
    
    public var body: some View {
        mainView
    }
}

extension GoalsView {
    private var mainView: some View {
        VStack(spacing: 0) {
            if goals.isEmpty {
                emptyStateView
            } else {
                goalsList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("목표가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("새로운 목표를 추가해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var goalsList: some View {
        List {
            ForEach(goals.sorted()) { goal in
                Button(action: {
                    select(goal)
                }) {
                    GoalCellView(goal: goal)
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct GoalCellView: View {
    let goal: GoalItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 인디케이터
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(goal.categoryDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(goal.todayDisplayTime + "s")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("오늘")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var categoryColor: Color {
        if let category = goal.category {
            return Color(hex: category.color) ?? .blue
        }
        return .gray
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        
        let startText = formatter.string(from: goal.startDate)
        
        if let endDate = goal.endDate {
            let endText = formatter.string(from: endDate)
            return "\(startText) ~ \(endText)"
        } else {
            return "\(startText) ~"
        }
    }
}
