//
//  Constants.swift
//  HealthTracker
//
//  App-wide constants and configuration
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Info
    static let appName = "HealthTracker"
    static let appBundleID = "com.deltafounder.healthtracker"

    // MARK: - Health Goals
    static let dailyStepsGoal = 10_000
    static let dailyWaterGoalML = 2_000.0
    static let recommendedSleepHours = 8.0

    // MARK: - Blood Sugar Ranges (mg/dL)
    enum BloodSugar {
        static let normalFastingMin = 70.0
        static let normalFastingMax = 100.0
        static let prediabetesMax = 125.0
        static let diabetesThreshold = 126.0
    }

    // MARK: - Blood Pressure Ranges (mmHg)
    enum BloodPressure {
        static let normalSystolic = 120
        static let normalDiastolic = 80
        static let elevatedSystolic = 130
        static let stage1Systolic = 140
        static let stage2Systolic = 180
        static let stage1Diastolic = 90
        static let stage2Diastolic = 120
    }

    // MARK: - Cholesterol Ranges (mg/dL)
    enum Cholesterol {
        static let totalDesirable = 200.0
        static let totalBorderline = 240.0
        static let ldlOptimal = 100.0
        static let ldlNearOptimal = 130.0
        static let hdlPoor = 40.0
        static let hdlGood = 60.0
    }

    // MARK: - Subscription
    enum Subscription {
        static let monthlyPrice = "$10"
        static let yearlyPrice = "$99"
        static let trialDays = 7
        static let monthlyProductID = "com.deltafounder.healthtracker.monthly"
        static let yearlyProductID = "com.deltafounder.healthtracker.yearly"
    }

    // MARK: - Notification IDs
    enum Notifications {
        static let morningBloodSugar = "morning_blood_sugar"
        static let eveningBloodSugar = "evening_blood_sugar"
        static let medication = "medication_reminder"
        static let waterPrefix = "water_reminder"
        static let activity = "activity_reminder"
    }

    // MARK: - Colors
    enum Colors {
        static let bloodSugar = Color.red
        static let bloodPressure = Color.pink
        static let cholesterol = Color.purple
        static let steps = Color.green
        static let sleep = Color.indigo
        static let food = Color.orange
        static let water = Color.cyan
    }

    // MARK: - API Keys (placeholder)
    enum API {
        static let openAIKey = "" // Configure in production
        static let nutritionAPIKey = "" // Configure in production
    }

    // MARK: - User Defaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isPremiumUser = "isPremiumUser"
        static let notificationsEnabled = "notificationsEnabled"
        static let healthKitSyncEnabled = "healthKitSyncEnabled"
        static let lastSyncDate = "lastSyncDate"
    }
}

// MARK: - Design System

enum DesignSystem {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }

    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title: CGFloat = 20
        static let largeTitle: CGFloat = 28
    }
}
