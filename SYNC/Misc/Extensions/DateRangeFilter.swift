//
//  DateRangeFilter.swift
//  SYNC
//
//  Created by Marcus Tiffen (CODING) on 01/11/2025.
//


enum DateRangeFilter: Equatable, CaseIterable {
    case all
    case today
    case tomorrow
    case thisWeek
    case thisMonth
    case custom(start: Date, end: Date)
    
    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .custom: return "Custom Range"
        }
    }
    
    var dateRange: (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return nil
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        case .tomorrow:
            let start = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        case .thisWeek:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return (start, end)
        case .thisMonth:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .custom(let start, let end):
            return (start, end)
        }
    }
    
    static var allCases: [DateRangeFilter] {
        [.all, .today, .tomorrow, .thisWeek, .thisMonth]
    }
    
    static func == (lhs: DateRangeFilter, rhs: DateRangeFilter) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.today, .today), (.tomorrow, .tomorrow),
             (.thisWeek, .thisWeek), (.thisMonth, .thisMonth):
            return true
        case (.custom(let lStart, let lEnd), .custom(let rStart, let rEnd)):
            return lStart == rStart && lEnd == rEnd
        default:
            return false
        }
    }
}