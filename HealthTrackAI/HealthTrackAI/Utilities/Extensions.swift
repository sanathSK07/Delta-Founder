//
//  Extensions.swift
//  HealthTrackAI
//
//  Swift extensions and utilities
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self)!
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

// MARK: - Double Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - View Extensions

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extensions

extension Color {
    static let customBackground = Color(UIColor.systemBackground)
    static let customSecondaryBackground = Color(UIColor.secondarySystemBackground)
}

// MARK: - String Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - Array Extensions

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = reduce(0, +)
        return sum / Double(count)
    }

    func standardDeviation() -> Double {
        guard !isEmpty else { return 0 }
        let avg = average()
        let squaredDiffs = map { pow($0 - avg, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(count)
        return sqrt(variance)
    }
}
