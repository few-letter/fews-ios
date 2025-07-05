//
//  CalendarUtils.swift
//  Toff
//
//  Created by 송영모 on 6/14/25.
//

import SwiftUI
import UIKit

// MARK: - Date Formatters
enum DateFormatters {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Comparable Extension
extension Comparable {
    /// 값을 지정된 범위로 제한
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - View Extensions
extension View {
    /// 특정 모서리에만 라운드 코너 적용
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    /// 두 날짜가 같은 주에 있는지 확인
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        let components1 = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date1)
        let components2 = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date2)
        return components1.yearForWeekOfYear == components2.yearForWeekOfYear &&
               components1.weekOfYear == components2.weekOfYear
    }
    
    /// 해당 월의 첫 번째 날짜 반환
    public func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    /// 해당 월의 마지막 날짜 반환
    public func endOfMonth(for date: Date) -> Date {
        let startOfNext = self.date(byAdding: .month, value: 1, to: startOfMonth(for: date))!
        return self.date(byAdding: .day, value: -1, to: startOfNext)!
    }
    
    /// 해당 주의 첫 번째 날짜 반환 (일요일 시작)
    public func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - Date Extensions
extension Date {
    /// 날짜를 해당 월의 몇 번째 주인지 반환
    func weekOfMonth(using calendar: Calendar = .current) -> Int {
        return calendar.component(.weekOfMonth, from: self)
    }
    
    /// 해당 날짜가 속한 월의 전체 주 수 반환
    func numberOfWeeksInMonth(using calendar: Calendar = .current) -> Int {
        let startOfMonth = calendar.startOfMonth(for: self)
        let endOfMonth = calendar.endOfMonth(for: self)
        
        let startWeek = calendar.component(.weekOfMonth, from: startOfMonth)
        let endWeek = calendar.component(.weekOfMonth, from: endOfMonth)
        
        return endWeek - startWeek + 1
    }
    
    /// 두 날짜 사이의 일 수 차이 반환
    func daysBetween(_ otherDate: Date, using calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([.day], from: self, to: otherDate)
        return components.day ?? 0
    }
}

// MARK: - Animation Presets
enum CalendarAnimations {
    static let springAnimation = Animation.interpolatingSpring(stiffness: 300, damping: 30)
    static let smoothAnimation = Animation.easeInOut(duration: 0.3)
    static let quickAnimation = Animation.easeInOut(duration: 0.15)
}

// MARK: - Calendar Constants
enum CalendarConstants {
    // Layout
    static let defaultPadding: CGFloat = 16
    static let cellSpacing: CGFloat = 2
    static let headerHeight: CGFloat = 24
    static let weekHeaderHeight: CGFloat = 16
    
    // Compact mode
    static let compactCellHeight: CGFloat = 40
    static let compactHandleHeight: CGFloat = 60
    
    // Event display
    static let maxVisibleEvents = 2
    static let eventFontSize: CGFloat = 6
    static let eventIndicatorSize: CGFloat = 4
    
    // Touch targets
    static let minimumTouchTarget: CGFloat = 44
    
    // Fractions
    static let defaultHeightFraction: CGFloat = 0.45
    static let minHeightFraction: CGFloat = 0.18
    static let maxHeightFraction: CGFloat = 0.9
    static let compactThreshold: CGFloat = 0.3
}

// MARK: - Error Types
enum CalendarError: Error, LocalizedError {
    case invalidDate
    case invalidDateRange
    case itemProviderError
    
    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Invalid date provided"
        case .invalidDateRange:
            return "Invalid date range"
        case .itemProviderError:
            return "Failed to load calendar items"
        }
    }
}

// MARK: - Debug Helpers
#if DEBUG
enum CalendarDebug {
    static func printDateInfo(_ date: Date, calendar: Calendar = .current) {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        
        print("Date: \(formatter.string(from: date))")
        print("Day of year: \(calendar.component(.dayOfYear, from: date))")
        print("Week of year: \(calendar.component(.weekOfYear, from: date))")
        print("Is today: \(calendar.isDateInToday(date))")
        print("Is weekend: \(calendar.isDateInWeekend(date))")
    }
    
    static func printItems<T: CalendarItem>(_ items: [T], for date: Date) {
        print("Items for \(DateFormatters.shortDate.string(from: date)):")
        for item in items {
            print("  - \(item.displayTitle)")
        }
    }
}
#endif
