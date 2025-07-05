//
//  CalendarModels.swift.swift
//  Toff
//
//  Created by 송영모 on 6/14/25.
//

import Foundation

// MARK: - Calendar Item Protocol
public protocol CalendarItem: Identifiable {
    /// 캘린더에 표시될 제목
    var displayTitle: String { get }
    
    /// 캘린더 셀에서 표시될 짧은 제목 (선택사항)
    var shortTitle: String { get }
}

extension CalendarItem {
    /// 기본적으로 displayTitle과 동일
    public var shortTitle: String { displayTitle }
}

// MARK: - Demo Calendar Item
struct DemoCalendarItem: CalendarItem {
    let id: Int
    let title: String
    
    var displayTitle: String { title }
    var shortTitle: String {
        // 긴 제목의 경우 줄임
        title.count > 8 ? String(title.prefix(6)) + "..." : title
    }
}

// MARK: - Demo Data Provider
extension DemoCalendarItem {
    static func sampleItems(for date: Date) -> [DemoCalendarItem] {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        if calendar.isDateInToday(date) {
            return (1...4).map {
                DemoCalendarItem(id: $0, title: "Today Event \($0)")
            }
        } else if day % 3 == 0 {
            return (1...2).map {
                DemoCalendarItem(
                    id: date.hashValue + $0,
                    title: "Event \($0) on \(day)th"
                )
            }
        } else if day % 5 == 0 {
            return [
                DemoCalendarItem(
                    id: date.hashValue,
                    title: "Important Meeting"
                )
            ]
        } else {
            return []
        }
    }
}

// MARK: - Real-world Example Models
/// 실제 사용 예시: 미팅 모델
struct MeetingItem: CalendarItem {
    let id = UUID()
    let title: String
    let startTime: Date
    let duration: TimeInterval
    let attendees: [String]
    
    var displayTitle: String { title }
    var shortTitle: String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return "\(timeFormatter.string(from: startTime)) \(title)"
    }
}

/// 실제 사용 예시: 태스크 모델
struct TaskItem: CalendarItem {
    let id = UUID()
    let title: String
    let priority: Priority
    let isCompleted: Bool
    
    enum Priority: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        
        var emoji: String {
            switch self {
            case .low: return "🟢"
            case .medium: return "🟡"
            case .high: return "🟠"
            case .urgent: return "🔴"
            }
        }
    }
    
    var displayTitle: String {
        let status = isCompleted ? "✅" : priority.emoji
        return "\(status) \(title)"
    }
    
    var shortTitle: String {
        let status = isCompleted ? "✅" : priority.emoji
        let shortTitle = title.count > 6 ? String(title.prefix(4)) + "..." : title
        return "\(status) \(shortTitle)"
    }
}
