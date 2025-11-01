//
//  User.swift
//  HealthTrackAI
//
//  User model
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var createdAt: Date
    var profile: UserProfile
    var subscription: Subscription
    var gamification: Gamification
    var currentPlan: DailyTargets?

    init(id: String? = nil, email: String, profile: UserProfile) {
        self.id = id
        self.email = email
        self.createdAt = Date()
        self.profile = profile
        self.subscription = Subscription()
        self.gamification = Gamification()
        self.currentPlan = nil
    }
}

struct UserProfile: Codable {
    var age: Int
    var sex: String
    var heightCm: Double
    var weightKg: Double
    var conditions: [String]
    var dietaryRestrictions: [String]
    var goals: [String]

    enum CodingKeys: String, CodingKey {
        case age, sex
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case conditions
        case dietaryRestrictions = "dietary_restrictions"
        case goals
    }
}

struct Subscription: Codable {
    var status: String
    var tier: String
    var startDate: Date?
    var nextBilling: Date?

    enum CodingKeys: String, CodingKey {
        case status, tier
        case startDate = "start_date"
        case nextBilling = "next_billing"
    }

    init() {
        self.status = "free"
        self.tier = "free"
        self.startDate = nil
        self.nextBilling = nil
    }
}

struct Gamification: Codable {
    var level: Int
    var xp: Int
    var currentStreak: Int
    var longestStreak: Int
    var trophies: [String]
    var healthPoints: Int

    enum CodingKeys: String, CodingKey {
        case level, xp
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case trophies
        case healthPoints = "health_points"
    }

    init() {
        self.level = 1
        self.xp = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.trophies = []
        self.healthPoints = 100
    }
}

struct DailyTargets: Codable {
    var caloriesPerDay: Int
    var carbsG: Int
    var proteinG: Int
    var fatG: Int

    enum CodingKeys: String, CodingKey {
        case caloriesPerDay = "calories_per_day"
        case carbsG = "carbs_g"
        case proteinG = "protein_g"
        case fatG = "fat_g"
    }
}
