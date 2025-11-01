//
//  PlanViewModel.swift
//  HealthTrackAI
//
//  Monthly plan ViewModel
//

import Foundation
import FirebaseAuth

@MainActor
class PlanViewModel: ObservableObject {
    @Published var currentPlan: MonthlyPlan?
    @Published var dailyTargets: DailyTargets?
    @Published var mealSuggestions: [MealSuggestion] = []
    @Published var isLoading = false

    private let firebaseService = FirebaseService.shared

    init() {
        Task {
            await loadCurrentPlan()
        }
    }

    // MARK: - Load Plan

    func loadCurrentPlan() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        isLoading = true

        do {
            currentPlan = try await firebaseService.fetchCurrentMonthPlan(userId: userId)

            if let plan = currentPlan {
                dailyTargets = plan.targets
                mealSuggestions = plan.mealSuggestions
            } else {
                // Generate initial plan if none exists
                await generateNewPlan()
            }
        } catch {
            print("Error loading plan: \(error)")
        }

        isLoading = false
    }

    // MARK: - Generate Plan

    func generateNewPlan() async {
        guard let userId = Auth.auth().currentUser?.uid,
              let user = try? await firebaseService.fetchUser(uid: userId) else {
            return
        }

        // Calculate targets based on user profile
        let targets = calculateTargets(for: user.profile)

        // Generate meal suggestions
        let suggestions = generateMealSuggestions(targets: targets, profile: user.profile)

        // Create plan
        let plan = MonthlyPlan(
            month: getCurrentMonthString(),
            generatedAt: Date(),
            targets: targets,
            adjustments: nil,
            mealSuggestions: suggestions
        )

        do {
            try await firebaseService.saveMonthlyPlan(plan, userId: userId)
            currentPlan = plan
            dailyTargets = targets
            mealSuggestions = suggestions
        } catch {
            print("Error saving plan: \(error)")
        }
    }

    // MARK: - Adjust Plan

    func adjustPlan(reason: String, calorieChange: Int) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let currentTargets = dailyTargets else {
            return
        }

        let newCalories = currentTargets.caloriesPerDay + calorieChange

        let newTargets = DailyTargets(
            caloriesPerDay: newCalories,
            carbsG: Int((Double(newCalories) * 0.4) / 4),
            proteinG: Int((Double(newCalories) * 0.3) / 4),
            fatG: Int((Double(newCalories) * 0.3) / 9)
        )

        let adjustments = PlanAdjustments(
            reason: reason,
            previousCalories: currentTargets.caloriesPerDay,
            change: calorieChange
        )

        let user = try? await firebaseService.fetchUser(uid: userId)
        let suggestions = generateMealSuggestions(targets: newTargets, profile: user?.profile ?? UserProfile(age: 30, sex: "male", heightCm: 175, weightKg: 80, conditions: [], dietaryRestrictions: [], goals: []))

        let plan = MonthlyPlan(
            month: getCurrentMonthString(),
            generatedAt: Date(),
            targets: newTargets,
            adjustments: adjustments,
            mealSuggestions: suggestions
        )

        do {
            try await firebaseService.saveMonthlyPlan(plan, userId: userId)
            currentPlan = plan
            dailyTargets = newTargets
            mealSuggestions = suggestions

            // Notify user
            NotificationManager.shared.sendMonthlyPlanReady()
        } catch {
            print("Error adjusting plan: \(error)")
        }
    }

    // MARK: - Calculate Targets

    private func calculateTargets(for profile: UserProfile) -> DailyTargets {
        // BMR calculation (Mifflin-St Jeor)
        let heightCm = profile.heightCm
        let weightKg = profile.weightKg
        let age = Double(profile.age)

        var bmr: Double
        if profile.sex.lowercased() == "male" {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161
        }

        // Activity factor
        let tdee = bmr * 1.3

        // Adjust for goals
        var targetCalories = tdee
        if profile.goals.contains("weight_loss") {
            targetCalories -= 500
        } else if profile.goals.contains("muscle_gain") {
            targetCalories += 300
        }

        // Macro split based on goals
        var carbPercent = 0.4
        var proteinPercent = 0.3
        var fatPercent = 0.3

        if profile.conditions.contains("diabetes") || profile.conditions.contains("pre-diabetic") {
            // Lower carbs for diabetes management
            carbPercent = 0.35
            proteinPercent = 0.35
            fatPercent = 0.3
        }

        return DailyTargets(
            caloriesPerDay: Int(targetCalories),
            carbsG: Int((targetCalories * carbPercent) / 4),
            proteinG: Int((targetCalories * proteinPercent) / 4),
            fatG: Int((targetCalories * fatPercent) / 9)
        )
    }

    // MARK: - Generate Meal Suggestions

    private func generateMealSuggestions(targets: DailyTargets, profile: UserProfile) -> [MealSuggestion] {
        let isVegetarian = profile.dietaryRestrictions.contains("vegetarian")
        let isVegan = profile.dietaryRestrictions.contains("vegan")
        let isDiabetic = profile.conditions.contains("diabetes") || profile.conditions.contains("pre-diabetic")

        var suggestions: [MealSuggestion] = []

        // Breakfast suggestions
        if isVegan {
            suggestions.append(MealSuggestion(
                name: "Overnight Oats with Berries",
                mealType: "breakfast",
                calories: 350,
                why: "High fiber keeps you full and stabilizes blood sugar"
            ))
        } else if isVegetarian {
            suggestions.append(MealSuggestion(
                name: "Greek Yogurt Bowl with Nuts",
                mealType: "breakfast",
                calories: 380,
                why: "High protein breakfast reduces glucose spikes throughout the day"
            ))
        } else {
            suggestions.append(MealSuggestion(
                name: "Scrambled Eggs with Avocado Toast",
                mealType: "breakfast",
                calories: 420,
                why: "Protein and healthy fats provide sustained energy"
            ))
        }

        // Lunch suggestions
        if isVegan {
            suggestions.append(MealSuggestion(
                name: "Quinoa Buddha Bowl",
                mealType: "lunch",
                calories: 450,
                why: "Complete protein with plenty of vegetables"
            ))
        } else if isVegetarian {
            suggestions.append(MealSuggestion(
                name: "Mediterranean Chickpea Salad",
                mealType: "lunch",
                calories: 420,
                why: "Fiber-rich and heart-healthy"
            ))
        } else {
            suggestions.append(MealSuggestion(
                name: "Grilled Chicken Salad",
                mealType: "lunch",
                calories: 480,
                why: "Lean protein with lots of vegetables keeps calories in check"
            ))
        }

        // Dinner suggestions
        if isVegan {
            suggestions.append(MealSuggestion(
                name: "Lentil Curry with Brown Rice",
                mealType: "dinner",
                calories: 500,
                why: "Plant-based protein and complex carbs"
            ))
        } else if isVegetarian {
            suggestions.append(MealSuggestion(
                name: "Vegetarian Stir-Fry with Tofu",
                mealType: "dinner",
                calories: 450,
                why: "High protein, low carb option"
            ))
        } else {
            suggestions.append(MealSuggestion(
                name: "Salmon with Roasted Vegetables",
                mealType: "dinner",
                calories: 520,
                why: "Omega-3 fatty acids support heart health and reduce inflammation"
            ))
        }

        // Snack suggestions
        if isDiabetic {
            suggestions.append(MealSuggestion(
                name: "Apple with Almond Butter",
                mealType: "snack",
                calories: 200,
                why: "Protein slows sugar absorption from the fruit"
            ))
        } else {
            suggestions.append(MealSuggestion(
                name: "Mixed Nuts and Dark Chocolate",
                mealType: "snack",
                calories: 180,
                why: "Healthy fats and antioxidants"
            ))
        }

        return suggestions
    }

    // MARK: - Helpers

    private func getCurrentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    // MARK: - Progress Tracking

    func calculateAdherence(meals: [Meal]) -> Double {
        guard let targets = dailyTargets else { return 0 }

        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
        var daysMetTarget = 0

        for day in 0..<daysInMonth {
            guard let date = Calendar.current.date(byAdding: .day, value: -day, to: Date()) else { continue }

            let dayMeals = meals.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
            let dayCalories = dayMeals.reduce(0) { $0 + $1.totals.calories }

            // Within 10% of target
            let target = Double(targets.caloriesPerDay)
            if dayCalories >= target * 0.9 && dayCalories <= target * 1.1 {
                daysMetTarget += 1
            }
        }

        return Double(daysMetTarget) / Double(daysInMonth)
    }
}
