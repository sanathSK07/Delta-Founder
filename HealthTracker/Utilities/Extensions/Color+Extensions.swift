//
//  Color+Extensions.swift
//  HealthTracker
//
//  Color extensions and custom colors
//

import SwiftUI

extension Color {
    // MARK: - Health Metric Colors

    static let bloodSugarColor = Color.red
    static let bloodPressureColor = Color.pink
    static let cholesterolColor = Color.purple
    static let stepsColor = Color.green
    static let sleepColor = Color.indigo
    static let foodColor = Color.orange
    static let waterColor = Color.cyan
    static let exerciseColor = Color.blue

    // MARK: - Status Colors

    static let statusLow = Color.blue
    static let statusNormal = Color.green
    static let statusElevated = Color.yellow
    static let statusHigh = Color.orange
    static let statusVeryHigh = Color.red
    static let statusCritical = Color.purple

    // MARK: - Custom Colors

    static let cardBackground = Color(.secondarySystemBackground)
    static let lightGray = Color(.systemGray6)

    // MARK: - Hex Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Gradient Helpers

    static func gradientForMetric(_ metric: String) -> LinearGradient {
        switch metric.lowercased() {
        case "blood sugar":
            return LinearGradient(
                colors: [.red.opacity(0.2), .orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "blood pressure":
            return LinearGradient(
                colors: [.pink.opacity(0.2), .red.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "cholesterol":
            return LinearGradient(
                colors: [.purple.opacity(0.2), .blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
