//
//  OnboardingViewModel.swift
//  HealthTracker
//
//  Handles onboarding flow and user profile creation
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var user = User()
    @Published var selectedConditions: Set<HealthCondition> = []
    @Published var selectedGoals: Set<HealthGoal> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let persistenceService = PersistenceService.shared
    private let healthKitService = HealthKitService.shared

    let totalSteps = 4

    // MARK: - Public Methods

    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func completeOnboarding() async {
        isLoading = true
        errorMessage = nil

        do {
            // Update user with selected conditions and goals
            user.conditions = Array(selectedConditions)
            user.goals = Array(selectedGoals)
            user.updatedAt = Date()

            // Save user profile
            try await persistenceService.saveUser(user)

            // Request HealthKit authorization
            await healthKitService.requestAuthorization()

            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

            isLoading = false
        } catch {
            errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Validation

    var canProceedFromStep: Bool {
        switch currentStep {
        case 0: // Welcome
            return !user.name.isEmpty
        case 1: // Basic info
            return user.age > 0 && user.weight > 0 && user.height > 0
        case 2: // Conditions
            return true // Optional
        case 3: // Goals
            return !selectedGoals.isEmpty
        default:
            return false
        }
    }

    var stepTitle: String {
        switch currentStep {
        case 0: return "Welcome"
        case 1: return "About You"
        case 2: return "Health Conditions"
        case 3: return "Your Goals"
        default: return ""
        }
    }

    var progressPercentage: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }
}
