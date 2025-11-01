//
//  MonthlyPlan.swift
//  HealthTrackAI
//
//  Monthly plan model
//

import Foundation
import FirebaseFirestore

struct MonthlyPlan: Identifiable, Codable {
    @DocumentID var id: String?
    var month: String
    var generatedAt: Date
    var targets: DailyTargets
    var adjustments: PlanAdjustments?
    var mealSuggestions: [MealSuggestion]

    enum CodingKeys: String, CodingKey {
        case id, month
        case generatedAt = "generated_at"
        case targets, adjustments
        case mealSuggestions = "meal_suggestions"
    }
}

struct PlanAdjustments: Codable {
    var reason: String
    var previousCalories: Int
    var change: Int

    enum CodingKeys: String, CodingKey {
        case reason
        case previousCalories = "previous_calories"
        case change
    }
}

struct MealSuggestion: Identifiable, Codable {
    var id: UUID
    var name: String
    var mealType: String
    var calories: Int
    var why: String
    var recipe: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case mealType = "meal_type"
        case calories, why, recipe
    }

    init(id: UUID = UUID(), name: String, mealType: String, calories: Int, why: String, recipe: String? = nil) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.calories = calories
        self.why = why
        self.recipe = recipe
    }
}
