//
//  HealthKitManager.swift
//  HealthTrackAI
//
//  HealthKit integration service
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    @Published var isAuthorized = false

    let readTypes: Set<HKSampleType> = [
        HKQuantityType(.bloodGlucose),
        HKQuantityType(.stepCount),
        HKQuantityType(.heartRate),
        HKQuantityType(.bodyMass),
        HKQuantityType(.bloodPressureSystolic),
        HKQuantityType(.bloodPressureDiastolic),
        HKCategoryType(.sleepAnalysis)
    ]

    init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func checkAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        // Check if we have authorization for glucose (representative check)
        let glucoseType = HKQuantityType(.bloodGlucose)
        let status = healthStore.authorizationStatus(for: glucoseType)
        isAuthorized = (status == .sharingAuthorized)
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: [], read: readTypes)

        await MainActor.run {
            self.isAuthorized = true
        }
    }

    // MARK: - Glucose Data

    func fetchGlucoseData(days: Int = 30) async throws -> [GlucoseReading] {
        let glucoseType = HKQuantityType(.bloodGlucose)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: glucoseType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let readings = samples.map { sample in
                    GlucoseReading(
                        value: sample.quantity.doubleValue(for: .milligramsPerDeciliter),
                        date: sample.startDate,
                        source: .appleHealth
                    )
                }
                continuation.resume(returning: readings)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Steps Data

    func fetchStepsForToday() async throws -> Double {
        let stepsType = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: steps)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Weight Data

    func fetchRecentWeights(days: Int = 30) async throws -> [(date: Date, value: Double)] {
        let weightType = HKQuantityType(.bodyMass)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let weights = samples.map { sample in
                    (date: sample.startDate, value: sample.quantity.doubleValue(for: .gramUnit(with: .kilo)))
                }
                continuation.resume(returning: weights)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Blood Pressure

    func fetchBloodPressure(days: Int = 30) async throws -> [(date: Date, systolic: Double, diastolic: Double)] {
        let systolicType = HKQuantityType(.bloodPressureSystolic)
        let diastolicType = HKQuantityType(.bloodPressureDiastolic)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        // Fetch systolic
        let systolicReadings = try await fetchQuantityData(type: systolicType, predicate: predicate)
        let diastolicReadings = try await fetchQuantityData(type: diastolicType, predicate: predicate)

        // Match readings by correlation (blood pressure readings are typically correlated)
        var results: [(date: Date, systolic: Double, diastolic: Double)] = []
        for systolic in systolicReadings {
            if let diastolic = diastolicReadings.first(where: { abs($0.date.timeIntervalSince(systolic.date)) < 60 }) {
                results.append((date: systolic.date, systolic: systolic.value, diastolic: diastolic.value))
            }
        }

        return results
    }

    private func fetchQuantityData(type: HKQuantityType, predicate: NSPredicate) async throws -> [(date: Date, value: Double)] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let unit: HKUnit = type == .bloodPressureSystolic || type == .bloodPressureDiastolic
                    ? .millimeterOfMercury()
                    : .count()

                let data = samples.map { sample in
                    (date: sample.startDate, value: sample.quantity.doubleValue(for: unit))
                }
                continuation.resume(returning: data)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Background Updates

    func enableBackgroundGlucoseUpdates(handler: @escaping (GlucoseReading?) -> Void) {
        let glucoseType = HKQuantityType(.bloodGlucose)

        let query = HKObserverQuery(sampleType: glucoseType, predicate: nil) { [weak self] query, completion, error in
            Task {
                if let readings = try? await self?.fetchGlucoseData(days: 1), let latest = readings.first {
                    handler(latest)
                } else {
                    handler(nil)
                }
            }
            completion()
        }

        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: glucoseType, frequency: .immediate) { success, error in
            if let error = error {
                print("Background delivery failed: \(error)")
            }
        }
    }
}

enum HealthKitError: Error {
    case notAvailable
    case authorizationDenied
}
