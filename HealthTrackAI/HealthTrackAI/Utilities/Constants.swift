//
//  Constants.swift
//  HealthTrackAI
//
//  App constants
//

import Foundation

struct AppConstants {
    // App Info
    static let appName = "HealthTrack AI"
    static let appVersion = "1.0.0"

    // Subscription
    static let monthlyProductID = "com.healthtrackai.premium.monthly"
    static let annualProductID = "com.healthtrackai.premium.annual"

    // Gamification
    static let xpPerMeal = 10
    static let xpPerHealthLog = 5
    static let xpPerTrophy = 50
    static let dailyGoalXP = 100

    // Health Targets
    static let defaultCalories = 2000
    static let defaultStepGoal = 8000
    static let targetGlucoseMin = 70.0
    static let targetGlucoseMax = 140.0
    static let targetBloodPressureSystolic = 120.0
    static let targetBloodPressureDiastolic = 80.0

    // App Settings
    static let minimumPhotoConfidence = 0.6
    static let maxDailyNotifications = 5
    static let defaultNotificationTimes = [
        (hour: 7, minute: 30, id: "breakfast"),
        (hour: 12, minute: 15, id: "lunch"),
        (hour: 18, minute: 45, id: "dinner")
    ]

    // URLs
    static let privacyPolicyURL = "https://example.com/privacy"
    static let termsOfServiceURL = "https://example.com/terms"
    static let supportEmail = "support@healthtrackai.com"
}

struct FirebaseCollections {
    static let users = "users"
    static let meals = "meals"
    static let healthLogs = "health_logs"
    static let monthlyPlans = "monthly_plans"
    static let predictions = "predictions"
    static let foodDatabase = "food_database"
}
