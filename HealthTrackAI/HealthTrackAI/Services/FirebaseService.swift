//
//  FirebaseService.swift
//  HealthTrackAI
//
//  Firebase Firestore service
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    // MARK: - User Operations

    func createUser(_ user: User, uid: String) async throws {
        try db.collection("users").document(uid).setData(from: user)
    }

    func fetchUser(uid: String) async throws -> User? {
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: User.self)
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        try await db.collection("users").document(uid).updateData(data)
    }

    // MARK: - Meal Operations

    func saveMeal(_ meal: Meal, userId: String) async throws -> String {
        let docRef = try db.collection("users/\(userId)/meals").addDocument(from: meal)
        return docRef.documentID
    }

    func fetchMeals(userId: String, limit: Int = 50) async throws -> [Meal] {
        let snapshot = try await db.collection("users/\(userId)/meals")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Meal.self) }
    }

    func fetchMealsForDateRange(userId: String, start: Date, end: Date) async throws -> [Meal] {
        let snapshot = try await db.collection("users/\(userId)/meals")
            .whereField("timestamp", isGreaterThanOrEqualTo: start)
            .whereField("timestamp", isLessThanOrEqualTo: end)
            .order(by: "timestamp", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Meal.self) }
    }

    func deleteMeal(mealId: String, userId: String) async throws {
        try await db.collection("users/\(userId)/meals").document(mealId).delete()
    }

    // MARK: - Health Log Operations

    func saveHealthLog(_ log: HealthLog, userId: String) async throws {
        try db.collection("users/\(userId)/health_logs").addDocument(from: log)
    }

    func fetchHealthLogs(userId: String, type: HealthLog.HealthLogType, days: Int) async throws -> [HealthLog] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let snapshot = try await db.collection("users/\(userId)/health_logs")
            .whereField("type", isEqualTo: type.rawValue)
            .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
            .order(by: "timestamp", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: HealthLog.self) }
    }

    // MARK: - Monthly Plan Operations

    func saveMonthlyPlan(_ plan: MonthlyPlan, userId: String) async throws {
        try db.collection("users/\(userId)/monthly_plans").addDocument(from: plan)
    }

    func fetchCurrentMonthPlan(userId: String) async throws -> MonthlyPlan? {
        let currentMonth = getCurrentMonthString()

        let snapshot = try await db.collection("users/\(userId)/monthly_plans")
            .whereField("month", isEqualTo: currentMonth)
            .limit(to: 1)
            .getDocuments()

        return snapshot.documents.first.flatMap { try? $0.data(as: MonthlyPlan.self) }
    }

    // MARK: - Food Database

    func searchFood(query: String) async throws -> [FoodItem] {
        // Simple search - in production, use Algolia or similar
        let snapshot = try await db.collection("food_database")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
            .limit(to: 10)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> FoodItem? in
            guard let data = doc.data() as? [String: Any],
                  let name = data["name"] as? String,
                  let nutrition = data["nutrition_per_100g"] as? [String: Any],
                  let calories = nutrition["calories"] as? Double,
                  let carbs = nutrition["carbs_g"] as? Double,
                  let protein = nutrition["protein_g"] as? Double,
                  let fat = nutrition["fat_g"] as? Double else {
                return nil
            }

            return FoodItem(
                name: name,
                calories: calories,
                carbsG: carbs,
                proteinG: protein,
                fatG: fat
            )
        }
    }

    // MARK: - Photo Upload

    func uploadMealPhoto(_ imageData: Data, userId: String, mealId: String) async throws -> String {
        let path = "users/\(userId)/meals/\(mealId).jpg"
        let storageRef = storage.reference().child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        return downloadURL.absoluteString
    }

    // MARK: - Gamification Updates

    func updateGamification(userId: String, xpToAdd: Int, hpChange: Int? = nil) async throws {
        let userRef = db.collection("users").document(userId)

        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var user = try? userDoc.data(as: User.self) else {
                return nil
            }

            // Update XP and level
            user.gamification.xp += xpToAdd
            user.gamification.level = LevelSystem.levelForXP(user.gamification.xp)

            // Update HP if provided
            if let hpChange = hpChange {
                user.gamification.healthPoints = max(0, min(100, user.gamification.healthPoints + hpChange))
            }

            try transaction.setData(from: user, forDocument: userRef)
            return nil
        })
    }

    func updateStreak(userId: String, newStreak: Int) async throws {
        try await db.collection("users").document(userId).updateData([
            "gamification.current_streak": newStreak,
            "gamification.longest_streak": FieldValue.arrayUnion([newStreak])
        ])
    }

    func unlockTrophy(userId: String, trophyId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "gamification.trophies": FieldValue.arrayUnion([trophyId])
        ])
    }

    // MARK: - Helpers

    private func getCurrentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
