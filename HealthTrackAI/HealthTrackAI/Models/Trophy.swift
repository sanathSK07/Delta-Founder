//
//  Trophy.swift
//  HealthTrackAI
//
//  Trophy model for gamification
//

import Foundation

struct Trophy: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: String
    var isUnlocked: Bool

    static let allTrophies: [Trophy] = [
        Trophy(id: "first_photo", name: "First Photo", description: "Log your first meal photo", icon: "camera.fill", requirement: "Log 1 meal with photo", isUnlocked: false),
        Trophy(id: "first_week", name: "First Week", description: "Complete 7 consecutive days", icon: "calendar.badge.checkmark", requirement: "7-day streak", isUnlocked: false),
        Trophy(id: "glucose_master", name: "Glucose Master", description: "30 days with glucose in target range", icon: "drop.fill", requirement: "30 days in range", isUnlocked: false),
        Trophy(id: "early_bird", name: "Early Bird", description: "Log breakfast 7 days in a row", icon: "sunrise.fill", requirement: "7 breakfast logs", isUnlocked: false),
        Trophy(id: "veggie_lover", name: "Veggie Lover", description: "Eat vegetables 5 days a week for a month", icon: "leaf.fill", requirement: "20 veggie meals", isUnlocked: false),
        Trophy(id: "streak_legend", name: "Streak Legend", description: "Achieve a 30-day streak", icon: "flame.fill", requirement: "30-day streak", isUnlocked: false),
        Trophy(id: "chef_novice", name: "Chef Novice", description: "Log 50 meals", icon: "fork.knife", requirement: "50 meals logged", isUnlocked: false),
        Trophy(id: "chef_master", name: "Chef Master", description: "Log 100 meals", icon: "star.fill", requirement: "100 meals logged", isUnlocked: false),
        Trophy(id: "health_scholar", name: "Health Scholar", description: "Read 10 AI insights", icon: "brain.head.profile", requirement: "Read 10 insights", isUnlocked: false),
        Trophy(id: "consistency_champion", name: "Consistency Champion", description: "Hit macro targets 20 days in a month", icon: "target", requirement: "20 days on target", isUnlocked: false)
    ]
}

struct LevelSystem {
    static func levelForXP(_ xp: Int) -> Int {
        return max(1, Int(sqrt(Double(xp) / 100)) + 1)
    }

    static func xpForNextLevel(_ currentXP: Int) -> Int {
        let currentLevel = levelForXP(currentXP)
        let nextLevel = currentLevel + 1
        return (nextLevel - 1) * (nextLevel - 1) * 100
    }

    static func xpProgressInCurrentLevel(_ xp: Int) -> (current: Int, needed: Int) {
        let currentLevel = levelForXP(xp)
        let xpForCurrentLevel = (currentLevel - 1) * (currentLevel - 1) * 100
        let xpForNextLevel = currentLevel * currentLevel * 100
        let currentProgress = xp - xpForCurrentLevel
        let neededForNext = xpForNextLevel - xpForCurrentLevel

        return (currentProgress, neededForNext)
    }
}
