//
//  ChartsViewModel.swift
//  HealthTracker
//
//  Manages health data visualization and analytics
//

import Foundation
import SwiftUI

enum ChartTimeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case year = "Year"

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
}

enum HealthMetricType: String, CaseIterable {
    case bloodSugar = "Blood Sugar"
    case bloodPressure = "Blood Pressure"
    case cholesterol = "Cholesterol"
    case weight = "Weight"
    case steps = "Steps"
    case sleep = "Sleep"

    var icon: String {
        switch self {
        case .bloodSugar: return "drop.fill"
        case .bloodPressure: return "heart.fill"
        case .cholesterol: return "waveform.path.ecg"
        case .weight: return "scalemass.fill"
        case .steps: return "figure.walk"
        case .sleep: return "bed.double.fill"
        }
    }
}

@MainActor
class ChartsViewModel: ObservableObject {
    @Published var selectedMetric: HealthMetricType = .bloodSugar
    @Published var selectedTimeframe: ChartTimeframe = .week
    @Published var bloodSugarData: [BloodSugar] = []
    @Published var bloodPressureData: [BloodPressure] = []
    @Published var cholesterolData: [Cholesterol] = []
    @Published var stepsData: [StepsEntry] = []
    @Published var sleepData: [SleepEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPaywall = false

    @AppStorage("isPremiumUser") private var isPremiumUser = false

    private let persistenceService = PersistenceService.shared

    // MARK: - Initialization

    init() {
        Task {
            await loadData()
        }
    }

    // MARK: - Public Methods

    func loadData() async {
        // Check premium for advanced insights
        if !isPremiumUser && (selectedTimeframe == .threeMonths || selectedTimeframe == .year) {
            showPaywall = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let startDate = Calendar.current.date(
                byAdding: .day,
                value: -selectedTimeframe.days,
                to: Date()
            ) ?? Date()

            switch selectedMetric {
            case .bloodSugar:
                bloodSugarData = try await persistenceService.getBloodSugarEntries(
                    from: startDate,
                    to: Date()
                )
            case .bloodPressure:
                bloodPressureData = try await persistenceService.getBloodPressureEntries(
                    from: startDate,
                    to: Date()
                )
            case .cholesterol:
                cholesterolData = try await persistenceService.getCholesterolEntries(
                    from: startDate,
                    to: Date()
                )
            case .steps:
                stepsData = try await persistenceService.getStepsEntries(
                    from: startDate,
                    to: Date()
                )
            case .sleep:
                sleepData = try await persistenceService.getSleepEntries(
                    from: startDate,
                    to: Date()
                )
            case .weight:
                // Implement weight tracking if needed
                break
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func changeMetric(_ metric: HealthMetricType) {
        selectedMetric = metric
        Task {
            await loadData()
        }
    }

    func changeTimeframe(_ timeframe: ChartTimeframe) {
        selectedTimeframe = timeframe
        Task {
            await loadData()
        }
    }

    // MARK: - Computed Properties

    var averageBloodSugar: Double? {
        guard !bloodSugarData.isEmpty else { return nil }
        return bloodSugarData.map { $0.value }.reduce(0, +) / Double(bloodSugarData.count)
    }

    var averageBloodPressure: (systolic: Double, diastolic: Double)? {
        guard !bloodPressureData.isEmpty else { return nil }
        let systolic = bloodPressureData.map { Double($0.systolic) }.reduce(0, +) / Double(bloodPressureData.count)
        let diastolic = bloodPressureData.map { Double($0.diastolic) }.reduce(0, +) / Double(bloodPressureData.count)
        return (systolic, diastolic)
    }

    var averageSteps: Double? {
        guard !stepsData.isEmpty else { return nil }
        return Double(stepsData.map { $0.count }.reduce(0, +)) / Double(stepsData.count)
    }

    var streakDays: Int {
        // Calculate consecutive days with data
        guard !bloodSugarData.isEmpty else { return 0 }

        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()

        for _ in 0..<30 {
            let hasDataForDay = bloodSugarData.contains { calendar.isDate($0.timestamp, inSameDayAs: currentDate) }
            if hasDataForDay {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        return streak
    }
}
