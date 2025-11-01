//
//  HealthLog.swift
//  HealthTrackAI
//
//  Health log model
//

import Foundation
import FirebaseFirestore

struct HealthLog: Identifiable, Codable {
    @DocumentID var id: String?
    var timestamp: Date
    var type: HealthLogType
    var value: Double
    var unit: String
    var source: DataSource
    var context: HealthContext?

    enum CodingKeys: String, CodingKey {
        case id, timestamp, type, value, unit, source, context
    }

    enum HealthLogType: String, Codable {
        case glucose
        case bloodPressureSystolic = "blood_pressure_systolic"
        case bloodPressureDiastolic = "blood_pressure_diastolic"
        case weight
        case cholesterolLDL = "cholesterol_ldl"
        case cholesterolHDL = "cholesterol_hdl"
        case steps
        case heartRate = "heart_rate"
        case sleep
    }

    enum DataSource: String, Codable {
        case appleHealth = "apple_health"
        case manual
    }
}

struct HealthContext: Codable {
    var mealId: String?
    var minutesAfterMeal: Int?

    enum CodingKeys: String, CodingKey {
        case mealId = "meal_id"
        case minutesAfterMeal = "minutes_after_meal"
    }
}

struct GlucoseReading: Identifiable {
    let id = UUID()
    let value: Double
    let date: Date
    let source: HealthLog.DataSource

    init(value: Double, date: Date, source: HealthLog.DataSource) {
        self.value = value
        self.date = date
        self.source = source
    }
}
