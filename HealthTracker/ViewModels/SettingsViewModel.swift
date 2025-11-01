//
//  SettingsViewModel.swift
//  HealthTracker
//
//  Manages app settings and user profile
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showExportSuccess = false
    @Published var isExporting = false

    @AppStorage("isPremiumUser") var isPremiumUser = false
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    @AppStorage("healthKitSyncEnabled") var healthKitSyncEnabled = false

    private let persistenceService = PersistenceService.shared
    private let notificationService = NotificationService.shared
    private let healthKitService = HealthKitService.shared

    // MARK: - Initialization

    init() {
        Task {
            await loadUserProfile()
        }
    }

    // MARK: - Public Methods

    func loadUserProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await persistenceService.loadUser()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func updateUserProfile(_ updatedUser: User) async {
        isLoading = true
        errorMessage = nil

        do {
            var userToSave = updatedUser
            userToSave.updatedAt = Date()
            try await persistenceService.saveUser(userToSave)
            user = userToSave
            isLoading = false
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func toggleNotifications() {
        notificationsEnabled.toggle()
        if notificationsEnabled {
            Task {
                await notificationService.scheduleReminders()
            }
        } else {
            notificationService.cancelAllNotifications()
        }
    }

    func toggleHealthKitSync() async {
        if !healthKitSyncEnabled {
            await healthKitService.requestAuthorization()
            healthKitSyncEnabled = healthKitService.isAuthorized
        } else {
            healthKitSyncEnabled = false
        }
    }

    func exportDataToPDF() async {
        isExporting = true
        errorMessage = nil

        do {
            // Gather all health data
            let bloodSugarData = try await persistenceService.getAllBloodSugarEntries()
            let bloodPressureData = try await persistenceService.getAllBloodPressureEntries()
            let cholesterolData = try await persistenceService.getAllCholesterolEntries()
            let foodData = try await persistenceService.getAllFoodEntries()

            // Generate PDF
            let pdfData = PDFExporter.shared.generateHealthReport(
                user: user,
                bloodSugar: bloodSugarData,
                bloodPressure: bloodPressureData,
                cholesterol: cholesterolData,
                foodEntries: foodData
            )

            // Save to Files
            try await savePDF(pdfData)

            showExportSuccess = true
            isExporting = false
        } catch {
            errorMessage = "Failed to export data: \(error.localizedDescription)"
            isExporting = false
        }
    }

    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        // App will restart and show onboarding
    }

    func deleteAllData() async {
        do {
            try await persistenceService.deleteAllData()
            resetOnboarding()
        } catch {
            errorMessage = "Failed to delete data: \(error.localizedDescription)"
        }
    }

    // MARK: - Private Methods

    private func savePDF(_ data: Data) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "HealthReport_\(dateFormatter.string(from: Date())).pdf"

        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        let pdfURL = documentsPath.appendingPathComponent(filename)

        try data.write(to: pdfURL)
    }

    // MARK: - Computed Properties

    var versionNumber: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var appVersion: String {
        "Version \(versionNumber) (\(buildNumber))"
    }
}
