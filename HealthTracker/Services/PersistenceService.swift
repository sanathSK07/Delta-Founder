//
//  PersistenceService.swift
//  HealthTracker
//
//  Handles data persistence using AppStorage and UserDefaults
//  For MVP - can be upgraded to CoreData later
//

import Foundation
import SwiftUI

class PersistenceService: ObservableObject {
    static let shared = PersistenceService()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - User Profile

    func saveUser(_ user: User) async throws {
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: "user_profile")
    }

    func loadUser() async throws -> User {
        guard let data = userDefaults.data(forKey: "user_profile"),
              let user = try? decoder.decode(User.self, from: data) else {
            throw PersistenceError.userNotFound
        }
        return user
    }

    // MARK: - Blood Sugar

    func saveBloodSugar(_ entry: BloodSugar) async throws {
        var entries = try await getAllBloodSugarEntries()
        entries.append(entry)
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "blood_sugar_entries")
    }

    func getAllBloodSugarEntries() async throws -> [BloodSugar] {
        guard let data = userDefaults.data(forKey: "blood_sugar_entries"),
              let entries = try? decoder.decode([BloodSugar].self, from: data) else {
            return []
        }
        return entries
    }

    func getLatestBloodSugar() async throws -> BloodSugar? {
        let entries = try await getAllBloodSugarEntries()
        return entries.sorted(by: { $0.timestamp > $1.timestamp }).first
    }

    func getBloodSugarEntries(from: Date, to: Date) async throws -> [BloodSugar] {
        let entries = try await getAllBloodSugarEntries()
        return entries.filter { $0.timestamp >= from && $0.timestamp <= to }
            .sorted(by: { $0.timestamp < $1.timestamp })
    }

    // MARK: - Blood Pressure

    func saveBloodPressure(_ entry: BloodPressure) async throws {
        var entries = try await getAllBloodPressureEntries()
        entries.append(entry)
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "blood_pressure_entries")
    }

    func getAllBloodPressureEntries() async throws -> [BloodPressure] {
        guard let data = userDefaults.data(forKey: "blood_pressure_entries"),
              let entries = try? decoder.decode([BloodPressure].self, from: data) else {
            return []
        }
        return entries
    }

    func getLatestBloodPressure() async throws -> BloodPressure? {
        let entries = try await getAllBloodPressureEntries()
        return entries.sorted(by: { $0.timestamp > $1.timestamp }).first
    }

    func getBloodPressureEntries(from: Date, to: Date) async throws -> [BloodPressure] {
        let entries = try await getAllBloodPressureEntries()
        return entries.filter { $0.timestamp >= from && $0.timestamp <= to }
            .sorted(by: { $0.timestamp < $1.timestamp })
    }

    // MARK: - Cholesterol

    func saveCholesterol(_ entry: Cholesterol) async throws {
        var entries = try await getAllCholesterolEntries()
        entries.append(entry)
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "cholesterol_entries")
    }

    func getAllCholesterolEntries() async throws -> [Cholesterol] {
        guard let data = userDefaults.data(forKey: "cholesterol_entries"),
              let entries = try? decoder.decode([Cholesterol].self, from: data) else {
            return []
        }
        return entries
    }

    func getLatestCholesterol() async throws -> Cholesterol? {
        let entries = try await getAllCholesterolEntries()
        return entries.sorted(by: { $0.timestamp > $1.timestamp }).first
    }

    func getCholesterolEntries(from: Date, to: Date) async throws -> [Cholesterol] {
        let entries = try await getAllCholesterolEntries()
        return entries.filter { $0.timestamp >= from && $0.timestamp <= to }
            .sorted(by: { $0.timestamp < $1.timestamp })
    }

    // MARK: - Food Entries

    func saveFoodEntry(_ entry: FoodEntry) async throws {
        var entries = try await getAllFoodEntries()
        entries.append(entry)
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "food_entries")
    }

    func getAllFoodEntries() async throws -> [FoodEntry] {
        guard let data = userDefaults.data(forKey: "food_entries"),
              let entries = try? decoder.decode([FoodEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func getFoodEntries(for date: Date) async throws -> [FoodEntry] {
        let entries = try await getAllFoodEntries()
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            .sorted(by: { $0.timestamp < $1.timestamp })
    }

    func getTodayCalories() async throws -> Double {
        let entries = try await getFoodEntries(for: Date())
        return entries.reduce(0) { $0 + $1.calories }
    }

    func deleteFoodEntry(_ entry: FoodEntry) async throws {
        var entries = try await getAllFoodEntries()
        entries.removeAll { $0.id == entry.id }
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "food_entries")
    }

    // MARK: - Steps

    func saveSteps(_ entry: StepsEntry) async throws {
        var entries = try await getAllStepsEntries()
        entries.append(entry)
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "steps_entries")
    }

    func getAllStepsEntries() async throws -> [StepsEntry] {
        guard let data = userDefaults.data(forKey: "steps_entries"),
              let entries = try? decoder.decode([StepsEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func getTodaySteps() async throws -> StepsEntry? {
        let entries = try await getAllStepsEntries()
        let calendar = Calendar.current
        return entries.first { calendar.isDateInToday($0.date) }
    }

    func getStepsEntries(from: Date, to: Date) async throws -> [StepsEntry] {
        let entries = try await getAllStepsEntries()
        return entries.filter { $0.date >= from && $0.date <= to }
            .sorted(by: { $0.date < $1.date })
    }

    // MARK: - Sleep

    func saveSleep(_ entry: SleepEntry) async throws {
        var entries = try await getAllSleepEntries()
        entries.append(entry)
        let data = try encoder.encode(entries)
        userDefaults.set(data, forKey: "sleep_entries")
    }

    func getAllSleepEntries() async throws -> [SleepEntry] {
        guard let data = userDefaults.data(forKey: "sleep_entries"),
              let entries = try? decoder.decode([SleepEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func getLastNightSleep() async throws -> SleepEntry? {
        let entries = try await getAllSleepEntries()
        return entries.sorted(by: { $0.wakeTime > $1.wakeTime }).first
    }

    func getSleepEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        let entries = try await getAllSleepEntries()
        return entries.filter { $0.bedTime >= from && $0.wakeTime <= to }
            .sorted(by: { $0.bedTime < $1.bedTime })
    }

    // MARK: - Utility

    func deleteAllData() async throws {
        let keys = [
            "user_profile",
            "blood_sugar_entries",
            "blood_pressure_entries",
            "cholesterol_entries",
            "food_entries",
            "steps_entries",
            "sleep_entries"
        ]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}

// MARK: - Errors

enum PersistenceError: Error, LocalizedError {
    case userNotFound
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .userNotFound: return "User profile not found"
        case .saveFailed: return "Failed to save data"
        case .loadFailed: return "Failed to load data"
        }
    }
}
