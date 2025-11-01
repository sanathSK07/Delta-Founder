//
//  MealViewModel.swift
//  HealthTrackAI
//
//  Meal logging ViewModel
//

import Foundation
import UIKit
import FirebaseAuth

@MainActor
class MealViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var todayMeals: [Meal] = []
    @Published var detectedFoods: [FoodItem] = []
    @Published var isAnalyzing = false
    @Published var showAddMeal = false
    @Published var todayCalories: Double = 0
    @Published var todaySteps: Double = 0

    private let firebaseService = FirebaseService.shared
    private let mlService = MLService.shared
    private let healthKitManager = HealthKitManager.shared

    init() {
        Task {
            await loadMeals()
            await loadTodayStats()
        }
    }

    // MARK: - Load Meals

    func loadMeals() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            meals = try await firebaseService.fetchMeals(userId: userId)
            updateTodayMeals()
        } catch {
            print("Error loading meals: \(error)")
        }
    }

    func loadMealsForRange(start: Date, end: Date) async -> [Meal] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }

        do {
            return try await firebaseService.fetchMealsForDateRange(userId: userId, start: start, end: end)
        } catch {
            print("Error loading meals for range: \(error)")
            return []
        }
    }

    private func updateTodayMeals() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        todayMeals = meals.filter { meal in
            calendar.isDate(meal.timestamp, inSameDayAs: Date())
        }

        todayCalories = todayMeals.reduce(0) { $0 + $1.totals.calories }
    }

    // MARK: - Analyze Photo

    func analyzePhoto(_ image: UIImage) async {
        isAnalyzing = true
        detectedFoods = []

        // Step 1: Recognize foods in image
        let predictions = await mlService.recognizeFood(from: image)

        // Step 2: Fetch nutrition data for each prediction
        var foods: [FoodItem] = []
        for prediction in predictions {
            if let nutritionData = await mlService.fetchNutritionData(for: prediction.name) {
                var food = nutritionData
                food.confidence = prediction.confidence
                foods.append(food)
            }
        }

        detectedFoods = foods
        isAnalyzing = false
    }

    // MARK: - Save Meal

    func saveMeal(foods: [FoodItem]? = nil, photo: UIImage? = nil) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let foodsToSave = foods ?? detectedFoods
        guard !foodsToSave.isEmpty else { return }

        // Calculate totals
        let totals = NutritionTotals.calculate(from: foodsToSave)

        // Determine meal type based on time
        let mealType = determineMealType()

        // Create meal
        var meal = Meal(
            timestamp: Date(),
            mealType: mealType,
            photoURL: nil,
            foods: foodsToSave,
            totals: totals,
            userEdited: false,
            xpEarned: 10,
            healthScore: 0
        )

        do {
            // Save meal to Firestore
            let mealId = try await firebaseService.saveMeal(meal, userId: userId)

            // Upload photo if available
            if let photo = photo, let imageData = photo.jpegData(compressionQuality: 0.7) {
                let photoURL = try await firebaseService.uploadMealPhoto(imageData, userId: userId, mealId: mealId)
                // Note: In production, you'd update the meal document with the photo URL
            }

            // Calculate health score (requires user's targets)
            // This would normally fetch from user's current plan
            let mockTargets = DailyTargets(caloriesPerDay: 2000, carbsG: 200, proteinG: 150, fatG: 67)
            meal.healthScore = mlService.calculateMealHealthScore(meal: meal, targets: mockTargets)

            // Award XP and update gamification
            try await firebaseService.updateGamification(userId: userId, xpToAdd: 10, hpChange: 5)

            // Reload meals
            await loadMeals()

            // Check for achievements
            await checkAchievements(userId: userId)

        } catch {
            print("Error saving meal: \(error)")
        }
    }

    func deleteMeal(_ meal: Meal) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let mealId = meal.id else { return }

        do {
            try await firebaseService.deleteMeal(mealId: mealId, userId: userId)
            await loadMeals()
        } catch {
            print("Error deleting meal: \(error)")
        }
    }

    // MARK: - Helpers

    private func determineMealType() -> Meal.MealType {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<22:
            return .dinner
        default:
            return .snack
        }
    }

    func loadTodayStats() async {
        // Load steps from HealthKit
        do {
            todaySteps = try await healthKitManager.fetchStepsForToday()
        } catch {
            print("Error loading steps: \(error)")
        }
    }

    // MARK: - Achievements

    private func checkAchievements(userId: String) async {
        // Check for "first photo" trophy
        if meals.count == 1 {
            try? await firebaseService.unlockTrophy(userId: userId, trophyId: "first_photo")
            NotificationManager.shared.sendTrophyUnlock(trophyName: "First Photo")
        }

        // Check for "chef novice" (50 meals)
        if meals.count == 50 {
            try? await firebaseService.unlockTrophy(userId: userId, trophyId: "chef_novice")
            NotificationManager.shared.sendTrophyUnlock(trophyName: "Chef Novice")
        }

        // Check for "chef master" (100 meals)
        if meals.count == 100 {
            try? await firebaseService.unlockTrophy(userId: userId, trophyId: "chef_master")
            NotificationManager.shared.sendTrophyUnlock(trophyName: "Chef Master")
        }

        // Check breakfast streak
        let breakfastCount = meals.filter { $0.mealType == .breakfast }.count
        if breakfastCount >= 7 {
            try? await firebaseService.unlockTrophy(userId: userId, trophyId: "early_bird")
        }
    }
}
