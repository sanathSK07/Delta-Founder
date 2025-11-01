//
//  MetricCard.swift
//  HealthTracker
//
//  Reusable metric card component
//

import SwiftUI

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    let status: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()

                if let status = status {
                    Text(status)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 140)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }

    private var statusColor: Color {
        guard let status = status else { return .gray }

        switch status.lowercased() {
        case "low": return .blue
        case "normal", "optimal", "good": return .green
        case "elevated", "borderline high": return .yellow
        case "high": return .orange
        case "very high", "crisis": return .red
        default: return .gray
        }
    }
}

#Preview {
    HStack {
        MetricCard(
            icon: "drop.fill",
            title: "Blood Sugar",
            value: "98",
            unit: "mg/dL",
            color: .red,
            status: "Normal"
        )

        MetricCard(
            icon: "heart.fill",
            title: "Blood Pressure",
            value: "120/80",
            unit: "mmHg",
            color: .pink,
            status: "Normal"
        )
    }
    .padding()
}
