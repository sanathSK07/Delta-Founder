//
//  Cholesterol.swift
//  HealthTracker
//
//  Cholesterol tracking model
//

import Foundation

struct Cholesterol: Codable, Identifiable {
    let id: UUID
    var totalCholesterol: Double // in mg/dL
    var ldl: Double? // LDL (bad cholesterol)
    var hdl: Double? // HDL (good cholesterol)
    var triglycerides: Double?
    var timestamp: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        totalCholesterol: Double,
        ldl: Double? = nil,
        hdl: Double? = nil,
        triglycerides: Double? = nil,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.totalCholesterol = totalCholesterol
        self.ldl = ldl
        self.hdl = hdl
        self.triglycerides = triglycerides
        self.timestamp = timestamp
        self.notes = notes
    }

    // MARK: - Computed Properties

    var totalCholesterolStatus: CholesterolStatus {
        if totalCholesterol < 200 { return .desirable }
        else if totalCholesterol < 240 { return .borderlineHigh }
        else { return .high }
    }

    var ldlStatus: CholesterolStatus? {
        guard let ldl = ldl else { return nil }
        if ldl < 100 { return .optimal }
        else if ldl < 130 { return .nearOptimal }
        else if ldl < 160 { return .borderlineHigh }
        else if ldl < 190 { return .high }
        else { return .veryHigh }
    }

    var hdlStatus: HDLStatus? {
        guard let hdl = hdl else { return nil }
        if hdl < 40 { return .poor }
        else if hdl < 60 { return .better }
        else { return .best }
    }

    var triglyceridesStatus: CholesterolStatus? {
        guard let triglycerides = triglycerides else { return nil }
        if triglycerides < 150 { return .normal }
        else if triglycerides < 200 { return .borderlineHigh }
        else if triglycerides < 500 { return .high }
        else { return .veryHigh }
    }

    var displayTotalCholesterol: String {
        String(format: "%.0f mg/dL", totalCholesterol)
    }
}

// MARK: - Supporting Types

enum CholesterolStatus: String {
    case optimal = "Optimal"
    case desirable = "Desirable"
    case nearOptimal = "Near Optimal"
    case normal = "Normal"
    case borderlineHigh = "Borderline High"
    case high = "High"
    case veryHigh = "Very High"

    var color: String {
        switch self {
        case .optimal, .desirable, .normal: return "green"
        case .nearOptimal, .borderlineHigh: return "yellow"
        case .high: return "orange"
        case .veryHigh: return "red"
        }
    }
}

enum HDLStatus: String {
    case poor = "Poor"
    case better = "Better"
    case best = "Best"

    var color: String {
        switch self {
        case .poor: return "red"
        case .better: return "yellow"
        case .best: return "green"
        }
    }

    var description: String {
        switch self {
        case .poor: return "Low HDL increases heart disease risk"
        case .better: return "Moderate HDL provides some protection"
        case .best: return "High HDL protects against heart disease"
        }
    }
}
