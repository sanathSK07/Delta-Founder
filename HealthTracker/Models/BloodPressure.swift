//
//  BloodPressure.swift
//  HealthTracker
//
//  Blood pressure tracking model
//

import Foundation

struct BloodPressure: Codable, Identifiable {
    let id: UUID
    var systolic: Int // in mmHg
    var diastolic: Int // in mmHg
    var heartRate: Int? // beats per minute
    var timestamp: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        systolic: Int,
        diastolic: Int,
        heartRate: Int? = nil,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.systolic = systolic
        self.diastolic = diastolic
        self.heartRate = heartRate
        self.timestamp = timestamp
        self.notes = notes
    }

    // MARK: - Computed Properties

    var status: BloodPressureStatus {
        if systolic < 90 || diastolic < 60 {
            return .low
        } else if systolic < 120 && diastolic < 80 {
            return .normal
        } else if systolic < 130 && diastolic < 80 {
            return .elevated
        } else if systolic < 140 || diastolic < 90 {
            return .stage1Hypertension
        } else if systolic < 180 || diastolic < 120 {
            return .stage2Hypertension
        } else {
            return .hypertensiveCrisis
        }
    }

    var displayValue: String {
        "\(systolic)/\(diastolic)"
    }

    var displayWithHeartRate: String {
        if let hr = heartRate {
            return "\(systolic)/\(diastolic) • \(hr) BPM"
        }
        return displayValue
    }
}

// MARK: - Supporting Types

enum BloodPressureStatus: String, CaseIterable {
    case low = "Low"
    case normal = "Normal"
    case elevated = "Elevated"
    case stage1Hypertension = "Stage 1 Hypertension"
    case stage2Hypertension = "Stage 2 Hypertension"
    case hypertensiveCrisis = "Hypertensive Crisis"

    var color: String {
        switch self {
        case .low: return "blue"
        case .normal: return "green"
        case .elevated: return "yellow"
        case .stage1Hypertension: return "orange"
        case .stage2Hypertension: return "red"
        case .hypertensiveCrisis: return "purple"
        }
    }

    var description: String {
        switch self {
        case .low:
            return "Your blood pressure is lower than normal. Consult your doctor if you feel dizzy or faint."
        case .normal:
            return "Your blood pressure is in a healthy range. Keep up the good work!"
        case .elevated:
            return "Your blood pressure is elevated. Consider lifestyle changes to prevent hypertension."
        case .stage1Hypertension:
            return "You have Stage 1 Hypertension. Talk to your doctor about treatment options."
        case .stage2Hypertension:
            return "You have Stage 2 Hypertension. Medical intervention is recommended."
        case .hypertensiveCrisis:
            return "This is a hypertensive crisis. Seek immediate medical attention!"
        }
    }
}
