//
//  FoodLogViewModel.swift
//  HealthTracker
//
//  Manages food logging and nutrition tracking
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class FoodLogViewModel: ObservableObject {
    @Published var foodEntries: [FoodEntry] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddFood = false
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var isAnalyzingPhoto = false

    private let persistenceService = PersistenceService.shared
    private let aiService = AIService.shared

    // MARK: - Initialization

    init() {
        Task {
            await loadFoodEntries()
        }
    }

    // MARK: - Public Methods

    func loadFoodEntries() async {
        isLoading = true
        errorMessage = nil

        do {
            foodEntries = try await persistenceService.getFoodEntries(for: selectedDate)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func addFoodEntry(_ entry: FoodEntry) async {
        do {
            try await persistenceService.saveFoodEntry(entry)
            await loadFoodEntries()
        } catch {
            errorMessage = "Failed to save food entry: \(error.localizedDescription)"
        }
    }

    func deleteFoodEntry(_ entry: FoodEntry) async {
        do {
            try await persistenceService.deleteFoodEntry(entry)
            await loadFoodEntries()
        } catch {
            errorMessage = "Failed to delete food entry: \(error.localizedDescription)"
        }
    }

    func analyzePhoto(_ image: UIImage) async {
        isAnalyzingPhoto = true
        errorMessage = nil

        do {
            // Placeholder for Vision/AI food recognition
            // This will be implemented with actual Vision framework or API
            let recognizedFood = try await aiService.recognizeFood(from: image)

            // For now, create a placeholder entry
            let entry = FoodEntry(
                name: recognizedFood.name,
                mealType: determineMealType(),
                calories: recognizedFood.calories,
                carbohydrates: recognizedFood.carbs,
                protein: recognizedFood.protein,
                fat: recognizedFood.fat,
                isVerified: true
            )

            await addFoodEntry(entry)
            isAnalyzingPhoto = false
        } catch {
            errorMessage = "Failed to analyze photo: \(error.localizedDescription)"
            isAnalyzingPhoto = false
        }
    }

    // MARK: - Computed Properties

    var totalCaloriesToday: Double {
        foodEntries.reduce(0) { $0 + $1.calories }
    }

    var totalCarbsToday: Double {
        foodEntries.compactMap { $0.carbohydrates }.reduce(0, +)
    }

    var totalProteinToday: Double {
        foodEntries.compactMap { $0.protein }.reduce(0, +)
    }

    var totalFatToday: Double {
        foodEntries.compactMap { $0.fat }.reduce(0, +)
    }

    var entriesByMealType: [MealType: [FoodEntry]] {
        Dictionary(grouping: foodEntries, by: { $0.mealType })
    }

    // MARK: - Private Methods

    private func determineMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return .breakfast
        case 11..<15: return .lunch
        case 15..<19: return .snack
        case 19..<23: return .dinner
        default: return .other
        }
    }
}
