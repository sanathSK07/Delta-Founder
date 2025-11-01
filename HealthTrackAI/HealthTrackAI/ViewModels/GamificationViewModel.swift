//
//  GamificationViewModel.swift
//  HealthTrackAI
//
//  Gamification ViewModel
//

import Foundation
import FirebaseAuth

@MainActor
class GamificationViewModel: ObservableObject {
    @Published var level: Int = 1
    @Published var xp: Int = 0
    @Published var xpForNextLevel: Int = 100
    @Published var xpProgress: Double = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var healthPoints: Int = 100
    @Published var trophies: [Trophy] = Trophy.allTrophies
    @Published var unlockedTrophyIds: [String] = []

    private let firebaseService = FirebaseService.shared

    init() {
        Task {
            await loadGamificationData()
        }
    }

    // MARK: - Load Data

    func loadGamificationData() async {
        guard let userId = Auth.auth().currentUser?.uid,
              let user = try? await firebaseService.fetchUser(uid: userId) else {
            return
        }

        level = user.gamification.level
        xp = user.gamification.xp
        currentStreak = user.gamification.currentStreak
        longestStreak = user.gamification.longestStreak
        healthPoints = user.gamification.healthPoints
        unlockedTrophyIds = user.gamification.trophies

        updateXPProgress()
        updateTrophyStatus()
    }

    // MARK: - XP Management

    func addXP(_ amount: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let previousLevel = level

        do {
            try await firebaseService.updateGamification(userId: userId, xpToAdd: amount)
            await loadGamificationData()

            // Check for level up
            if level > previousLevel {
                // Level up celebration
                NotificationManager.shared.sendTrophyUnlock(trophyName: "Level \(level) Reached!")
            }
        } catch {
            print("Error adding XP: \(error)")
        }
    }

    private func updateXPProgress() {
        let progress = LevelSystem.xpProgressInCurrentLevel(xp)
        xpProgress = Double(progress.current) / Double(progress.needed)
        xpForNextLevel = progress.needed
    }

    // MARK: - HP Management

    func updateHP(change: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            try await firebaseService.updateGamification(userId: userId, xpToAdd: 0, hpChange: change)
            await loadGamificationData()
        } catch {
            print("Error updating HP: \(error)")
        }
    }

    func resetDailyHP() async {
        // Reset HP to 100 at start of each day
        healthPoints = 100
        await updateHP(change: 0)
    }

    // MARK: - Streak Management

    func updateStreak() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // Check if user logged meals today
        let mealVM = MealViewModel()
        await mealVM.loadMeals()

        let hasLoggedToday = !mealVM.todayMeals.isEmpty

        if hasLoggedToday {
            // Check if they logged yesterday
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let yesterdayMeals = await mealVM.loadMealsForRange(
                start: Calendar.current.startOfDay(for: yesterday),
                end: Calendar.current.date(byAdding: .day, value: 1, to: yesterday)!
            )

            let newStreak = yesterdayMeals.isEmpty ? 1 : currentStreak + 1

            do {
                try await firebaseService.updateStreak(userId: userId, newStreak: newStreak)
                currentStreak = newStreak

                if newStreak > longestStreak {
                    longestStreak = newStreak
                }

                // Send celebration notifications
                if newStreak == 7 || newStreak == 30 || newStreak % 10 == 0 {
                    NotificationManager.shared.sendStreakCelebration(streak: newStreak)
                }

                // Unlock streak trophies
                if newStreak == 7 {
                    await unlockTrophy("first_week")
                }
                if newStreak == 30 {
                    await unlockTrophy("streak_legend")
                }
            } catch {
                print("Error updating streak: \(error)")
            }
        } else {
            // Streak broken
            currentStreak = 0
        }
    }

    // MARK: - Trophy Management

    func unlockTrophy(_ trophyId: String) async {
        guard let userId = Auth.auth().currentUser?.uid,
              !unlockedTrophyIds.contains(trophyId) else {
            return
        }

        do {
            try await firebaseService.unlockTrophy(userId: userId, trophyId: trophyId)
            unlockedTrophyIds.append(trophyId)
            updateTrophyStatus()

            // Find trophy name for notification
            if let trophy = Trophy.allTrophies.first(where: { $0.id == trophyId }) {
                NotificationManager.shared.sendTrophyUnlock(trophyName: trophy.name)
            }

            // Award bonus XP for trophy
            await addXP(50)
        } catch {
            print("Error unlocking trophy: \(error)")
        }
    }

    private func updateTrophyStatus() {
        trophies = Trophy.allTrophies.map { trophy in
            var updatedTrophy = trophy
            updatedTrophy.isUnlocked = unlockedTrophyIds.contains(trophy.id)
            return updatedTrophy
        }
    }

    var unlockedTrophies: [Trophy] {
        trophies.filter { $0.isUnlocked }
    }

    var lockedTrophies: [Trophy] {
        trophies.filter { !$0.isUnlocked }
    }

    // MARK: - Daily Check

    func performDailyCheck() async {
        await updateStreak()
        await resetDailyHP()
    }
}
