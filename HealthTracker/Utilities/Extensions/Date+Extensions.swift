//
//  Date+Extensions.swift
//  HealthTracker
//
//  Date formatting and utility extensions
//

import Foundation

extension Date {
    // MARK: - Formatting

    /// Returns a string like "Jan 15, 2024"
    var mediumDateString: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns a string like "3:45 PM"
    var shortTimeString: String {
        formatted(date: .omitted, time: .shortened)
    }

    /// Returns a string like "Jan 15, 3:45 PM"
    var mediumDateTimeString: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    /// Returns a string like "Today", "Yesterday", or "Jan 15"
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            return mediumDateString
        }
    }

    // MARK: - Date Components

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }

    // MARK: - Comparison

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func isSameWeek(as date: Date) -> Bool {
        let calendar = Calendar.current
        let comp1 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let comp2 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return comp1.yearForWeekOfYear == comp2.yearForWeekOfYear &&
               comp1.weekOfYear == comp2.weekOfYear
    }

    func isSameMonth(as date: Date) -> Bool {
        let calendar = Calendar.current
        let comp1 = calendar.dateComponents([.year, .month], from: self)
        let comp2 = calendar.dateComponents([.year, .month], from: date)
        return comp1.year == comp2.year && comp1.month == comp2.month
    }

    // MARK: - Time Ago

    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    // MARK: - Date Math

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startOfDay, to: date.startOfDay)
        return abs(components.day ?? 0)
    }

    // MARK: - Common Date Presets

    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }

    static var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

    static var oneWeekAgo: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    }

    static var oneMonthAgo: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    }

    static var threeMonthsAgo: Date {
        Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    }

    static var oneYearAgo: Date {
        Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    }
}
