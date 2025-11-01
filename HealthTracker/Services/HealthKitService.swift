//
//  HealthKitService.swift
//  HealthTracker
//
//  HealthKit integration for reading and writing health data
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                isAuthorized = true
            }
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Read Data

    func getTodaySteps() async -> Int? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return nil
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            healthStore.execute(query)
        }
    }

    func getLastNightSleep() async -> SleepEntry? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            ) { _, samples, error in
                guard let sample = samples?.first as? HKCategorySample,
                      sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue else {
                    continuation.resume(returning: nil)
                    return
                }

                let sleepEntry = SleepEntry(
                    bedTime: sample.startDate,
                    wakeTime: sample.endDate,
                    quality: .good
                )
                continuation.resume(returning: sleepEntry)
            }
            healthStore.execute(query)
        }
    }

    func getBloodGlucose(from startDate: Date, to endDate: Date) async -> [BloodSugar] {
        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            return []
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: glucoseType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let entries = samples.map { sample -> BloodSugar in
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "mg/dL"))
                    return BloodSugar(
                        value: value,
                        measurementType: .random,
                        timestamp: sample.startDate
                    )
                }
                continuation.resume(returning: entries)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Write Data

    func saveBloodGlucose(_ value: Double, date: Date) async throws {
        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            throw HealthKitError.invalidType
        }

        let quantity = HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: value)
        let sample = HKQuantitySample(type: glucoseType, quantity: quantity, start: date, end: date)

        try await healthStore.save(sample)
    }

    func saveBloodPressure(systolic: Int, diastolic: Int, date: Date) async throws {
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            throw HealthKitError.invalidType
        }

        let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(systolic))
        let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(diastolic))

        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: date, end: date)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: date, end: date)

        try await healthStore.save([systolicSample, diastolicSample])
    }

    func saveWeight(_ weight: Double, date: Date) async throws {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            throw HealthKitError.invalidType
        }

        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let sample = HKQuantitySample(type: weightType, quantity: quantity, start: date, end: date)

        try await healthStore.save(sample)
    }
}

// MARK: - Errors

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationFailed
    case invalidType
    case saveFailed
    case readFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable: return "HealthKit is not available on this device"
        case .authorizationFailed: return "HealthKit authorization failed"
        case .invalidType: return "Invalid HealthKit data type"
        case .saveFailed: return "Failed to save data to HealthKit"
        case .readFailed: return "Failed to read data from HealthKit"
        }
    }
}
