//
//  DashboardViewModel.swift
//  HealthTracker
//
//  Manages dashboard data and health metrics display
//

import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var user: User?
    @Published var latestBloodSugar: BloodSugar?
    @Published var latestBloodPressure: BloodPressure?
    @Published var latestCholesterol: Cholesterol?
    @Published var todaySteps: StepsEntry?
    @Published var lastNightSleep: SleepEntry?
    @Published var todayCalories: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPaywall = false

    private let persistenceService = PersistenceService.shared
    private let healthKitService = HealthKitService.shared

    // MARK: - Initialization

    init() {
        Task {
            await loadData()
        }
    }

    // MARK: - Public Methods

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load user profile
            user = try await persistenceService.loadUser()

            // Load latest metrics
            latestBloodSugar = try await persistenceService.getLatestBloodSugar()
            latestBloodPressure = try await persistenceService.getLatestBloodPressure()
            latestCholesterol = try await persistenceService.getLatestCholesterol()
            todaySteps = try await persistenceService.getTodaySteps()
            lastNightSleep = try await persistenceService.getLastNightSleep()
            todayCalories = try await persistenceService.getTodayCalories()

            // Sync with HealthKit if authorized
            if healthKitService.isAuthorized {
                await syncHealthKitData()
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func refresh() async {
        await loadData()
    }

    // MARK: - Private Methods

    private func syncHealthKitData() async {
        // Sync steps
        if let steps = await healthKitService.getTodaySteps() {
            todaySteps = StepsEntry(count: steps)
        }

        // Sync sleep
        if let sleep = await healthKitService.getLastNightSleep() {
            lastNightSleep = sleep
        }

        // Additional HealthKit syncs can be added here
    }

    // MARK: - Computed Properties

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = user?.name ?? "there"

        switch hour {
        case 0..<12:
            return "Good morning, \(name)!"
        case 12..<17:
            return "Good afternoon, \(name)!"
        default:
            return "Good evening, \(name)!"
        }
    }

    var healthScore: Int {
        var score = 0
        var totalMetrics = 0

        // Blood sugar
        if let bs = latestBloodSugar {
            totalMetrics += 1
            if bs.status == .normal { score += 1 }
        }

        // Blood pressure
        if let bp = latestBloodPressure {
            totalMetrics += 1
            if bp.status == .normal { score += 1 }
        }

        // Cholesterol
        if let chol = latestCholesterol {
            totalMetrics += 1
            if chol.totalCholesterolStatus == .desirable { score += 1 }
        }

        // Steps
        if let steps = todaySteps, steps.count >= 7000 {
            totalMetrics += 1
            score += 1
        }

        // Sleep
        if let sleep = lastNightSleep, sleep.status == .optimal {
            totalMetrics += 1
            score += 1
        }

        guard totalMetrics > 0 else { return 0 }
        return Int((Double(score) / Double(totalMetrics)) * 100)
    }
}
