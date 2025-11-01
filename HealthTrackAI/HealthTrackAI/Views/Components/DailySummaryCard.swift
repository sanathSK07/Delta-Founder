//
//  DailySummaryCard.swift
//  HealthTrackAI
//
//  Daily summary component
//

import SwiftUI

struct DailySummaryCard: View {
    let mealsLogged: Int
    let totalCalories: Int
    let calorieGoal: Int
    let steps: Int
    let stepGoal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Summary")
                .font(.headline)

            // Meals
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.blue)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Meals Logged")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(mealsLogged)/3")
                        .font(.body)
                        .bold()
                }

                Spacer()

                CircularProgressView(
                    progress: Double(mealsLogged) / 3.0,
                    lineWidth: 6,
                    color: .blue
                )
                .frame(width: 50, height: 50)
            }

            Divider()

            // Calories
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalCalories) / \(calorieGoal)")
                        .font(.body)
                        .bold()
                }

                Spacer()

                CircularProgressView(
                    progress: Double(totalCalories) / Double(calorieGoal),
                    lineWidth: 6,
                    color: .orange
                )
                .frame(width: 50, height: 50)
            }

            Divider()

            // Steps
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.green)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(steps) / \(stepGoal)")
                        .font(.body)
                        .bold()
                }

                Spacer()

                CircularProgressView(
                    progress: Double(steps) / Double(stepGoal),
                    lineWidth: 6,
                    color: .green
                )
                .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
        }
    }
}
