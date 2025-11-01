//
//  MLService.swift
//  HealthTrackAI
//
//  Machine Learning service for food recognition and predictions
//

import Foundation
import UIKit
import Vision
import CoreML

class MLService {
    static let shared = MLService()

    private init() {}

    // MARK: - Food Recognition

    func recognizeFood(from image: UIImage) async -> [FoodPrediction] {
        // In production, you would load your trained CoreML model here
        // For MVP, we'll use a simulated recognition with common foods

        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Return simulated results - in production, this would be actual ML inference
        return generateMockFoodPredictions()
    }

    private func generateMockFoodPredictions() -> [FoodPrediction] {
        // Common foods for demo purposes
        let commonFoods = [
            ("Grilled Chicken Breast", 0.92),
            ("Brown Rice", 0.88),
            ("Scrambled Eggs", 0.91),
            ("Banana", 0.95),
            ("Greek Yogurt", 0.89),
            ("Salmon Fillet", 0.87),
            ("Mixed Salad", 0.85),
            ("Avocado Toast", 0.93),
            ("Oatmeal", 0.90),
            ("Chicken Caesar Salad", 0.86)
        ]

        // Randomly select 1-3 foods
        let count = Int.random(in: 1...3)
        return commonFoods.shuffled().prefix(count).map { FoodPrediction(name: $0.0, confidence: $0.1) }
    }

    // MARK: - Nutrition Lookup

    func fetchNutritionData(for foodName: String) async -> FoodItem? {
        // In production, query Firebase food database or USDA API
        // For MVP, return common nutrition values

        let nutritionDatabase: [String: (calories: Double, carbs: Double, protein: Double, fat: Double)] = [
            "Grilled Chicken Breast": (165, 0, 31, 3.6),
            "Brown Rice": (112, 24, 2.3, 0.9),
            "Scrambled Eggs": (140, 2, 12, 10),
            "Banana": (105, 27, 1.3, 0.4),
            "Greek Yogurt": (100, 6, 17, 0.7),
            "Salmon Fillet": (206, 0, 22, 13),
            "Mixed Salad": (33, 7, 2.5, 0.3),
            "Avocado Toast": (250, 26, 7, 15),
            "Oatmeal": (150, 27, 5, 3),
            "Chicken Caesar Salad": (320, 12, 28, 18)
        ]

        guard let nutrition = nutritionDatabase[foodName] else {
            // Default values if not found
            return FoodItem(
                name: foodName,
                calories: 200,
                carbsG: 20,
                proteinG: 10,
                fatG: 8
            )
        }

        return FoodItem(
            name: foodName,
            calories: nutrition.calories,
            carbsG: nutrition.carbs,
            proteinG: nutrition.protein,
            fatG: nutrition.fat,
            servingSize: 100,
            servingUnit: "g"
        )
    }

    // MARK: - Glucose Prediction

    func predictGlucose(historicalReadings: [Double]) async -> [GlucosePrediction] {
        // In production, this would use a trained LSTM CoreML model
        // For MVP, use simple moving average with random variance

        guard !historicalReadings.isEmpty else {
            return []
        }

        let recentAverage = historicalReadings.suffix(7).reduce(0, +) / Double(min(7, historicalReadings.count))

        return (1...7).map { day in
            let variance = Double.random(in: -10...10)
            let predicted = recentAverage + variance

            GlucosePrediction(
                daysAhead: day,
                predictedValue: max(70, min(180, predicted)),
                confidenceLower: max(60, predicted - 15),
                confidenceUpper: min(200, predicted + 15)
            )
        }
    }

    // MARK: - Health Score Calculation

    func calculateHealthScore(
        glucoseReadings: [Double],
        mealAdherence: Double,
        activityLevel: Double,
        sleepQuality: Double
    ) -> Int {
        var score = 0

        // Glucose stability (0-30 points)
        let avgGlucose = glucoseReadings.isEmpty ? 100 : glucoseReadings.reduce(0, +) / Double(glucoseReadings.count)
        let glucoseStdDev = calculateStandardDeviation(glucoseReadings)

        if avgGlucose >= 70 && avgGlucose <= 120 {
            score += 20
        } else if avgGlucose > 120 && avgGlucose <= 140 {
            score += 10
        }

        if glucoseStdDev < 20 {
            score += 10
        } else if glucoseStdDev < 30 {
            score += 5
        }

        // Meal adherence (0-30 points)
        score += Int(mealAdherence * 30)

        // Activity level (0-20 points)
        score += Int(activityLevel * 20)

        // Sleep quality (0-20 points)
        score += Int(sleepQuality * 20)

        return max(0, min(100, score))
    }

    func calculateMealHealthScore(meal: Meal, targets: DailyTargets) -> Int {
        let totals = meal.totals
        var score = 10 // Base score

        // Protein content (good!)
        if totals.proteinG >= 15 {
            score += 2
        }

        // Calorie appropriateness (for a single meal, should be ~1/3 of daily)
        let targetPerMeal = Double(targets.caloriesPerDay) / 3.0
        let calorieDiff = abs(totals.calories - targetPerMeal)
        if calorieDiff < 100 {
            score += 2
        } else if calorieDiff < 200 {
            score += 1
        }

        // Macro balance
        let totalGrams = totals.carbsG + totals.proteinG + totals.fatG
        if totalGrams > 0 {
            let carbPercent = (totals.carbsG * 4 / totals.calories) * 100
            let proteinPercent = (totals.proteinG * 4 / totals.calories) * 100
            let fatPercent = (totals.fatG * 9 / totals.calories) * 100

            // Ideal ranges: 40% carbs, 30% protein, 30% fat
            if proteinPercent >= 25 && proteinPercent <= 35 {
                score += 2
            }
            if carbPercent >= 35 && carbPercent <= 50 {
                score += 1
            }
            if fatPercent >= 20 && fatPercent <= 35 {
                score += 1
            }
        }

        return max(1, min(10, score))
    }

    // MARK: - Risk Scoring

    func calculateRiskScore(
        avgGlucose: Double,
        avgBP: (systolic: Double, diastolic: Double)?,
        avgLDL: Double?,
        bmi: Double
    ) -> (score: Int, risk: RiskLevel) {
        var riskPoints = 0

        // Glucose risk
        if avgGlucose > 140 {
            riskPoints += 3
        } else if avgGlucose > 126 {
            riskPoints += 2
        } else if avgGlucose > 100 {
            riskPoints += 1
        }

        // Blood pressure risk
        if let bp = avgBP {
            if bp.systolic > 140 || bp.diastolic > 90 {
                riskPoints += 3
            } else if bp.systolic > 130 || bp.diastolic > 85 {
                riskPoints += 2
            }
        }

        // LDL cholesterol risk
        if let ldl = avgLDL {
            if ldl > 160 {
                riskPoints += 3
            } else if ldl > 130 {
                riskPoints += 2
            } else if ldl > 100 {
                riskPoints += 1
            }
        }

        // BMI risk
        if bmi > 30 {
            riskPoints += 2
        } else if bmi > 25 {
            riskPoints += 1
        }

        let riskLevel: RiskLevel
        if riskPoints >= 6 {
            riskLevel = .high
        } else if riskPoints >= 3 {
            riskLevel = .moderate
        } else {
            riskLevel = .low
        }

        return (riskPoints * 10, riskLevel)
    }

    // MARK: - Helpers

    private func calculateStandardDeviation(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }

        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(values.count)

        return sqrt(variance)
    }
}

// MARK: - Supporting Types

struct FoodPrediction {
    let name: String
    let confidence: Double
}

struct GlucosePrediction: Identifiable {
    let id = UUID()
    let daysAhead: Int
    let predictedValue: Double
    let confidenceLower: Double
    let confidenceUpper: Double
}

enum RiskLevel: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}
