//
//  Exercise.swift
//  HealthTracker
//
//  Exercise and activity tracking model
//

import Foundation

struct Exercise: Codable, Identifiable {
    let id: UUID
    var type: ExerciseType
    var duration: TimeInterval // in seconds
    var distance: Double? // in meters
    var caloriesBurned: Double?
    var steps: Int?
    var heartRate: Int? // average BPM
    var timestamp: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        type: ExerciseType,
        duration: TimeInterval,
        distance: Double? = nil,
        caloriesBurned: Double? = nil,
        steps: Int? = nil,
        heartRate: Int? = nil,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.duration = duration
        self.distance = distance
        self.caloriesBurned = caloriesBurned
        self.steps = steps
        self.heartRate = heartRate
        self.timestamp = timestamp
        self.notes = notes
    }

    // MARK: - Computed Properties

    var displayDuration: String {
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var displayDistance: String? {
        guard let distance = distance else { return nil }
        let km = distance / 1000
        return String(format: "%.2f km", km)
    }

    var displayCalories: String? {
        guard let calories = caloriesBurned else { return nil }
        return String(format: "%.0f cal", calories)
    }
}

// MARK: - Supporting Types

enum ExerciseType: String, Codable, CaseIterable {
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case yoga = "Yoga"
    case strength = "Strength Training"
    case dancing = "Dancing"
    case hiking = "Hiking"
    case sports = "Sports"
    case other = "Other"

    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.mind.and.body"
        case .strength: return "dumbbell.fill"
        case .dancing: return "music.note"
        case .hiking: return "mountain.2.fill"
        case .sports: return "sportscourt.fill"
        case .other: return "figure.mixed.cardio"
        }
    }

    var color: String {
        switch self {
        case .walking: return "green"
        case .running: return "red"
        case .cycling: return "blue"
        case .swimming: return "cyan"
        case .yoga: return "purple"
        case .strength: return "orange"
        case .dancing: return "pink"
        case .hiking: return "brown"
        case .sports: return "yellow"
        case .other: return "gray"
        }
    }
}
