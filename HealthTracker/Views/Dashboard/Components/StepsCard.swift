//
//  StepsCard.swift
//  HealthTracker
//
//  Steps metric card
//

import SwiftUI

struct StepsCard: View {
    let steps: StepsEntry?

    var body: some View {
        if let stepsEntry = steps {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                        .font(.title3)

                    Spacer()

                    Text("\(Int(stepsEntry.goalProgress * 100))%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }

                Text("Steps")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(stepsEntry.displayCount)
                    .font(.title2)
                    .fontWeight(.bold)

                ProgressView(value: stepsEntry.goalProgress)
                    .tint(.green)
            }
            .padding()
            .frame(height: 140)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3)
        } else {
            EmptyMetricCard(
                icon: "figure.walk",
                title: "Steps",
                color: .green
            )
        }
    }
}

#Preview {
    VStack {
        StepsCard(steps: StepsEntry(count: 7543))
        StepsCard(steps: nil)
    }
    .padding()
}
