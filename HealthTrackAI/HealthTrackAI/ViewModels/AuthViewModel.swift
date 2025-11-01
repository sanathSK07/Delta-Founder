//
//  AuthViewModel.swift
//  HealthTrackAI
//
//  Authentication ViewModel
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth = Auth.auth()
    private let firebaseService = FirebaseService.shared

    init() {
        checkAuth()
    }

    func checkAuth() {
        if let firebaseUser = auth.currentUser {
            isAuthenticated = true
            Task {
                await fetchUserProfile(uid: firebaseUser.uid)
            }
        }
    }

    func signUp(email: String, password: String, profile: UserProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await auth.createUser(withEmail: email, password: password)

            // Create user document
            let newUser = User(id: result.user.uid, email: email, profile: profile)
            try await firebaseService.createUser(newUser, uid: result.user.uid)

            // Generate initial plan
            let initialPlan = generateInitialPlan(for: profile)
            try await firebaseService.updateUser(uid: result.user.uid, data: [
                "currentPlan": [
                    "calories_per_day": initialPlan.caloriesPerDay,
                    "carbs_g": initialPlan.carbsG,
                    "protein_g": initialPlan.proteinG,
                    "fat_g": initialPlan.fatG
                ]
            ])

            self.user = newUser
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await fetchUserProfile(uid: result.user.uid)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() {
        do {
            try auth.signOut()
            isAuthenticated = false
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchUserProfile(uid: String) async {
        do {
            if let fetchedUser = try await firebaseService.fetchUser(uid: uid) {
                self.user = fetchedUser
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }

    func updateUserProfile(_ updates: [String: Any]) async {
        guard let uid = auth.currentUser?.uid else { return }

        do {
            try await firebaseService.updateUser(uid: uid, data: updates)
            await fetchUserProfile(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // MARK: - Initial Plan Generation

    private func generateInitialPlan(for profile: UserProfile) -> DailyTargets {
        // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
        let heightCm = profile.heightCm
        let weightKg = profile.weightKg
        let age = Double(profile.age)

        var bmr: Double
        if profile.sex.lowercased() == "male" {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161
        }

        // Apply activity factor (assume sedentary to lightly active)
        let tdee = bmr * 1.3

        // Adjust for goals
        var targetCalories = tdee
        if profile.goals.contains("weight_loss") || profile.goals.contains("Weight Loss") {
            targetCalories -= 500 // 500 calorie deficit for ~1 lb/week loss
        }

        // Calculate macros (40% carbs, 30% protein, 30% fat)
        let carbs = Int((targetCalories * 0.4) / 4)
        let protein = Int((targetCalories * 0.3) / 4)
        let fat = Int((targetCalories * 0.3) / 9)

        return DailyTargets(
            caloriesPerDay: Int(targetCalories),
            carbsG: carbs,
            proteinG: protein,
            fatG: fat
        )
    }
}
