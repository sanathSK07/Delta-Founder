//
//  BloodSugarCard.swift
//  HealthTracker
//
//  Blood sugar metric card
//

import SwiftUI

struct BloodSugarCard: View {
    let bloodSugar: BloodSugar?

    var body: some View {
        if let bs = bloodSugar {
            MetricCard(
                icon: "drop.fill",
                title: "Blood Sugar",
                value: bs.displayValue,
                unit: bs.unit.rawValue,
                color: .red,
                status: bs.status.rawValue
            )
        } else {
            EmptyMetricCard(
                icon: "drop.fill",
                title: "Blood Sugar",
                color: .red
            )
        }
    }
}

struct EmptyMetricCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color.opacity(0.5))
                .font(.title3)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text("No data")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button {
                // Action to add data
            } label: {
                Text("Add Entry")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(height: 140)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

#Preview {
    VStack {
        BloodSugarCard(bloodSugar: BloodSugar(value: 105, measurementType: .fasting))
        BloodSugarCard(bloodSugar: nil)
    }
    .padding()
}
