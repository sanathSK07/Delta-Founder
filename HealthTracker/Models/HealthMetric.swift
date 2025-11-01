//
//  HealthMetric.swift
//  HealthTracker
//
//  General health metrics model for sleep, steps, water, etc.
//

import Foundation

struct SleepEntry: Codable, Identifiable {
    let id: UUID
    var bedTime: Date
    var wakeTime: Date
    var quality: SleepQuality
    var notes: String?

    init(
        id: UUID = UUID(),
        bedTime: Date,
        wakeTime: Date,
        quality: SleepQuality = .good,
        notes: String? = nil
    ) {
        self.id = id
        self.bedTime = bedTime
        self.wakeTime = wakeTime
        self.quality = quality
        self.notes = notes
    }

    // MARK: - Computed Properties

    var duration: TimeInterval {
        wakeTime.timeIntervalSince(bedTime)
    }

    var displayDuration: String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }

    var status: SleepStatus {
        let hours = duration / 3600
        if hours < 6 { return .insufficient }
        else if hours < 7 { return .short }
        else if hours <= 9 { return .optimal }
        else { return .long }
    }
}

enum SleepQuality: String, Codable, CaseIterable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"

    var icon: String {
        switch self {
        case .poor: return "moon.zzz"
        case .fair: return "moon"
        case .good: return "moon.stars"
        case .excellent: return "moon.stars.fill"
        }
    }

    var color: String {
        switch self {
        case .poor: return "red"
        case .fair: return "orange"
        case .good: return "yellow"
        case .excellent: return "green"
        }
    }
}

enum SleepStatus: String {
    case insufficient = "Insufficient"
    case short = "Short"
    case optimal = "Optimal"
    case long = "Long"

    var color: String {
        switch self {
        case .insufficient: return "red"
        case .short: return "orange"
        case .optimal: return "green"
        case .long: return "yellow"
        }
    }
}

// MARK: - Steps

struct StepsEntry: Codable, Identifiable {
    let id: UUID
    var count: Int
    var date: Date

    init(id: UUID = UUID(), count: Int, date: Date = Date()) {
        self.id = id
        self.count = count
        self.date = date
    }

    var goalProgress: Double {
        let goal = 10000.0
        return min(Double(count) / goal, 1.0)
    }

    var displayCount: String {
        if count >= 1000 {
            let k = Double(count) / 1000.0
            return String(format: "%.1fK", k)
        }
        return "\(count)"
    }
}

// MARK: - Water Intake

struct WaterEntry: Codable, Identifiable {
    let id: UUID
    var amount: Double // in ml
    var timestamp: Date

    init(id: UUID = UUID(), amount: Double, timestamp: Date = Date()) {
        self.id = id
        self.amount = amount
        self.timestamp = timestamp
    }

    var displayAmount: String {
        if amount >= 1000 {
            let liters = amount / 1000.0
            return String(format: "%.1fL", liters)
        }
        return String(format: "%.0fml", amount)
    }
}
