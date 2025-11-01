//
//  HealthViewModel.swift
//  HealthTrackAI
//
//  Health data ViewModel
//

import Foundation
import FirebaseAuth

@MainActor
class HealthViewModel: ObservableObject {
    @Published var glucoseReadings: [GlucoseReading] = []
    @Published var weightData: [(date: Date, value: Double)] = []
    @Published var bloodPressureData: [(date: Date, systolic: Double, diastolic: Double)] = []
    @Published var predictions: [GlucosePrediction] = []
    @Published var healthScore: Int = 75
    @Published var isLoading = false

    private let healthKitManager = HealthKitManager.shared
    private let firebaseService = FirebaseService.shared
    private let mlService = MLService.shared

    // MARK: - Load Health Data

    func loadAllHealthData() async {
        isLoading = true

        await loadGlucoseData()
        await loadWeightData()
        await loadBloodPressureData()
        await generatePredictions()
        await calculateHealthScore()

        isLoading = false
    }

    func loadGlucoseData(days: Int = 30) async {
        do {
            glucoseReadings = try await healthKitManager.fetchGlucoseData(days: days)
        } catch {
            print("Error loading glucose data: \(error)")
        }
    }

    func loadWeightData(days: Int = 90) async {
        do {
            weightData = try await healthKitManager.fetchRecentWeights(days: days)
        } catch {
            print("Error loading weight data: \(error)")
        }
    }

    func loadBloodPressureData(days: Int = 30) async {
        do {
            bloodPressureData = try await healthKitManager.fetchBloodPressure(days: days)
        } catch {
            print("Error loading blood pressure data: \(error)")
        }
    }

    // MARK: - Manual Entry

    func logGlucose(value: Double) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let log = HealthLog(
            timestamp: Date(),
            type: .glucose,
            value: value,
            unit: "mg/dL",
            source: .manual
        )

        do {
            try await firebaseService.saveHealthLog(log, userId: userId)
            await loadGlucoseData()

            // Check for spike alert
            if value > 180 {
                NotificationManager.shared.sendGlucoseSpikeAlert(value: value, mealName: nil)
            }
        } catch {
            print("Error logging glucose: \(error)")
        }
    }

    func logBloodPressure(systolic: Double, diastolic: Double) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let systolicLog = HealthLog(
            timestamp: Date(),
            type: .bloodPressureSystolic,
            value: systolic,
            unit: "mmHg",
            source: .manual
        )

        let diastolicLog = HealthLog(
            timestamp: Date(),
            type: .bloodPressureDiastolic,
            value: diastolic,
            unit: "mmHg",
            source: .manual
        )

        do {
            try await firebaseService.saveHealthLog(systolicLog, userId: userId)
            try await firebaseService.saveHealthLog(diastolicLog, userId: userId)
            await loadBloodPressureData()
        } catch {
            print("Error logging blood pressure: \(error)")
        }
    }

    // MARK: - Predictions

    func generatePredictions() async {
        let glucoseValues = glucoseReadings.map { $0.value }
        predictions = await mlService.predictGlucose(historicalReadings: glucoseValues)
    }

    // MARK: - Health Score

    func calculateHealthScore() async {
        let glucoseValues = glucoseReadings.map { $0.value }

        // For MVP, use simplified metrics
        let mealAdherence = 0.8 // Would calculate from actual meal logs
        let activityLevel = 0.7 // Would calculate from steps
        let sleepQuality = 0.75 // Would fetch from HealthKit

        healthScore = mlService.calculateHealthScore(
            glucoseReadings: glucoseValues,
            mealAdherence: mealAdherence,
            activityLevel: activityLevel,
            sleepQuality: sleepQuality
        )
    }

    // MARK: - Alerts

    func checkForAlerts() async {
        // Check glucose spikes
        if let latestGlucose = glucoseReadings.first, latestGlucose.value > 180 {
            NotificationManager.shared.sendGlucoseSpikeAlert(
                value: latestGlucose.value,
                mealName: "your recent meal"
            )
        }

        // Check inactivity (would normally check HealthKit steps)
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour >= 18 {
            // Would check actual step count here
            // NotificationManager.shared.sendInactivityNudge(currentSteps: steps, goal: 8000)
        }
    }

    // MARK: - Analytics

    func averageGlucose(for days: Int) -> Double {
        let relevantReadings = glucoseReadings.filter {
            let daysAgo = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
            return $0.date >= daysAgo
        }

        guard !relevantReadings.isEmpty else { return 0 }
        let sum = relevantReadings.reduce(0) { $0 + $1.value }
        return sum / Double(relevantReadings.count)
    }

    func glucoseTrend(for days: Int) -> Double {
        guard glucoseReadings.count >= 2 else { return 0 }

        let recent = averageGlucose(for: days)
        let previous = averageGlucose(for: days * 2)

        guard previous > 0 else { return 0 }
        return ((recent - previous) / previous) * 100
    }
}
