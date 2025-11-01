//
//  User.swift
//  HealthTracker
//
//  User profile model with onboarding data
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var age: Int
    var weight: Double // in kg
    var height: Double // in cm
    var weightUnit: WeightUnit
    var heightUnit: HeightUnit
    var conditions: [HealthCondition]
    var goals: [HealthGoal]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        age: Int = 0,
        weight: Double = 0,
        height: Double = 0,
        weightUnit: WeightUnit = .kg,
        heightUnit: HeightUnit = .cm,
        conditions: [HealthCondition] = [],
        goals: [HealthGoal] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.weight = weight
        self.height = height
        self.weightUnit = weightUnit
        self.heightUnit = heightUnit
        self.conditions = conditions
        self.goals = goals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Supporting Types

enum WeightUnit: String, Codable, CaseIterable {
    case kg = "kg"
    case lbs = "lbs"

    var displayName: String {
        switch self {
        case .kg: return "Kilograms"
        case .lbs: return "Pounds"
        }
    }
}

enum HeightUnit: String, Codable, CaseIterable {
    case cm = "cm"
    case ft = "ft/in"

    var displayName: String {
        switch self {
        case .cm: return "Centimeters"
        case .ft: return "Feet/Inches"
        }
    }
}

enum HealthCondition: String, Codable, CaseIterable {
    case diabetes = "Diabetes"
    case hypertension = "Hypertension"
    case highCholesterol = "High Cholesterol"
    case prediabetes = "Prediabetes"
    case obesity = "Obesity"
    case sleepApnea = "Sleep Apnea"
    case other = "Other"

    var icon: String {
        switch self {
        case .diabetes, .prediabetes: return "cross.case.fill"
        case .hypertension: return "heart.text.square.fill"
        case .highCholesterol: return "waveform.path.ecg"
        case .obesity: return "figure.walk"
        case .sleepApnea: return "bed.double.fill"
        case .other: return "staroflife.fill"
        }
    }
}

enum HealthGoal: String, Codable, CaseIterable {
    case lowerBloodSugar = "Lower Blood Sugar"
    case lowerBloodPressure = "Lower Blood Pressure"
    case lowerCholesterol = "Lower Cholesterol"
    case loseWeight = "Lose Weight"
    case increaseActivity = "Increase Activity"
    case betterSleep = "Better Sleep"
    case healthierEating = "Healthier Eating"

    var icon: String {
        switch self {
        case .lowerBloodSugar: return "drop.fill"
        case .lowerBloodPressure: return "heart.fill"
        case .lowerCholesterol: return "waveform"
        case .loseWeight: return "scalemass.fill"
        case .increaseActivity: return "figure.walk"
        case .betterSleep: return "moon.stars.fill"
        case .healthierEating: return "leaf.fill"
        }
    }
}
