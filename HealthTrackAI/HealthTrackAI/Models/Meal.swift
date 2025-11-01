//
//  Meal.swift
//  HealthTrackAI
//
//  Meal model
//

import Foundation
import FirebaseFirestore

struct Meal: Identifiable, Codable {
    @DocumentID var id: String?
    var timestamp: Date
    var mealType: MealType
    var photoURL: String?
    var foods: [FoodItem]
    var totals: NutritionTotals
    var userEdited: Bool
    var xpEarned: Int
    var healthScore: Int

    enum CodingKeys: String, CodingKey {
        case id, timestamp
        case mealType = "meal_type"
        case photoURL = "photo_url"
        case foods, totals
        case userEdited = "user_edited"
        case xpEarned = "xp_earned"
        case healthScore = "health_score"
    }

    enum MealType: String, Codable {
        case breakfast, lunch, dinner, snack
    }
}

struct FoodItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var calories: Double
    var carbsG: Double
    var proteinG: Double
    var fatG: Double
    var servingSize: Double
    var servingUnit: String
    var confidence: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, calories
        case carbsG = "carbs_g"
        case proteinG = "protein_g"
        case fatG = "fat_g"
        case servingSize = "serving_size"
        case servingUnit = "serving_unit"
        case confidence
    }

    init(id: UUID = UUID(), name: String, calories: Double, carbsG: Double, proteinG: Double, fatG: Double, servingSize: Double = 100, servingUnit: String = "g", confidence: Double? = nil) {
        self.id = id
        self.name = name
        self.calories = calories
        self.carbsG = carbsG
        self.proteinG = proteinG
        self.fatG = fatG
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.confidence = confidence
    }
}

struct NutritionTotals: Codable {
    var calories: Double
    var carbsG: Double
    var proteinG: Double
    var fatG: Double

    enum CodingKeys: String, CodingKey {
        case calories
        case carbsG = "carbs_g"
        case proteinG = "protein_g"
        case fatG = "fat_g"
    }

    static func calculate(from foods: [FoodItem]) -> NutritionTotals {
        let totalCalories = foods.reduce(0) { $0 + $1.calories }
        let totalCarbs = foods.reduce(0) { $0 + $1.carbsG }
        let totalProtein = foods.reduce(0) { $0 + $1.proteinG }
        let totalFat = foods.reduce(0) { $0 + $1.fatG }

        return NutritionTotals(
            calories: totalCalories,
            carbsG: totalCarbs,
            proteinG: totalProtein,
            fatG: totalFat
        )
    }
}
