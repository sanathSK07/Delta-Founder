//
//  BloodSugar.swift
//  HealthTracker
//
//  Blood glucose tracking model
//

import Foundation

struct BloodSugar: Codable, Identifiable {
    let id: UUID
    var value: Double // in mg/dL
    var unit: BloodSugarUnit
    var measurementType: MeasurementType
    var timestamp: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        value: Double,
        unit: BloodSugarUnit = .mgDL,
        measurementType: MeasurementType,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.value = value
        self.unit = unit
        self.measurementType = measurementType
        self.timestamp = timestamp
        self.notes = notes
    }

    // MARK: - Computed Properties

    /// Returns the status based on measurement type and value
    var status: BloodSugarStatus {
        switch measurementType {
        case .fasting:
            if value < 70 { return .low }
            else if value <= 100 { return .normal }
            else if value <= 125 { return .prediabetic }
            else { return .high }

        case .beforeMeal:
            if value < 70 { return .low }
            else if value <= 130 { return .normal }
            else { return .high }

        case .afterMeal:
            if value < 70 { return .low }
            else if value <= 180 { return .normal }
            else { return .high }

        case .bedtime:
            if value < 90 { return .low }
            else if value <= 150 { return .normal }
            else { return .high }

        case .random:
            if value < 70 { return .low }
            else if value <= 200 { return .normal }
            else { return .high }
        }
    }

    var displayValue: String {
        String(format: "%.0f", value)
    }
}

// MARK: - Supporting Types

enum BloodSugarUnit: String, Codable, CaseIterable {
    case mgDL = "mg/dL"
    case mmolL = "mmol/L"

    var displayName: String { rawValue }
}

enum MeasurementType: String, Codable, CaseIterable {
    case fasting = "Fasting"
    case beforeMeal = "Before Meal"
    case afterMeal = "After Meal"
    case bedtime = "Bedtime"
    case random = "Random"

    var icon: String {
        switch self {
        case .fasting: return "sunrise.fill"
        case .beforeMeal: return "fork.knife"
        case .afterMeal: return "fork.knife.circle.fill"
        case .bedtime: return "moon.fill"
        case .random: return "clock.fill"
        }
    }
}

enum BloodSugarStatus: String {
    case low = "Low"
    case normal = "Normal"
    case prediabetic = "Prediabetic"
    case high = "High"

    var color: String {
        switch self {
        case .low: return "blue"
        case .normal: return "green"
        case .prediabetic: return "yellow"
        case .high: return "red"
        }
    }
}
