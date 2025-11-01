//
//  BloodPressureCard.swift
//  HealthTracker
//
//  Blood pressure metric card
//

import SwiftUI

struct BloodPressureCard: View {
    let bloodPressure: BloodPressure?

    var body: some View {
        if let bp = bloodPressure {
            MetricCard(
                icon: "heart.fill",
                title: "Blood Pressure",
                value: bp.displayValue,
                unit: "mmHg",
                color: .pink,
                status: bp.status.rawValue
            )
        } else {
            EmptyMetricCard(
                icon: "heart.fill",
                title: "Blood Pressure",
                color: .pink
            )
        }
    }
}

#Preview {
    VStack {
        BloodPressureCard(bloodPressure: BloodPressure(systolic: 120, diastolic: 80))
        BloodPressureCard(bloodPressure: nil)
    }
    .padding()
}
