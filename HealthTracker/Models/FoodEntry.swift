//
//  FoodEntry.swift
//  HealthTracker
//
//  Food logging model with nutrition tracking
//

import Foundation

struct FoodEntry: Codable, Identifiable {
    let id: UUID
    var name: String
    var mealType: MealType
    var calories: Double
    var carbohydrates: Double? // in grams
    var protein: Double? // in grams
    var fat: Double? // in grams
    var fiber: Double? // in grams
    var sugar: Double? // in grams
    var sodium: Double? // in mg
    var servingSize: String?
    var timestamp: Date
    var notes: String?
    var photoURL: String? // Local file path or URL
    var isVerified: Bool // Whether analyzed by AI or manually entered

    init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType,
        calories: Double,
        carbohydrates: Double? = nil,
        protein: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodium: Double? = nil,
        servingSize: String? = nil,
        timestamp: Date = Date(),
        notes: String? = nil,
        photoURL: String? = nil,
        isVerified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.calories = calories
        self.carbohydrates = carbohydrates
        self.protein = protein
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.servingSize = servingSize
        self.timestamp = timestamp
        self.notes = notes
        self.photoURL = photoURL
        self.isVerified = isVerified
    }

    // MARK: - Computed Properties

    var displayCalories: String {
        String(format: "%.0f cal", calories)
    }

    var macroSummary: String {
        var components: [String] = []
        if let carbs = carbohydrates {
            components.append(String(format: "%.0fg carbs", carbs))
        }
        if let protein = protein {
            components.append(String(format: "%.0fg protein", protein))
        }
        if let fat = fat {
            components.append(String(format: "%.0fg fat", fat))
        }
        return components.joined(separator: " • ")
    }
}

// MARK: - Supporting Types

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case other = "Other"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        case .other: return "fork.knife"
        }
    }

    var color: String {
        switch self {
        case .breakfast: return "orange"
        case .lunch: return "yellow"
        case .dinner: return "purple"
        case .snack: return "green"
        case .other: return "gray"
        }
    }
}
