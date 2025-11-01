//
//  MealCardView.swift
//  HealthTrackAI
//
//  Meal card component
//

import SwiftUI

struct MealCardView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            // Meal icon
            ZStack {
                Circle()
                    .fill(mealTypeColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: mealTypeIcon)
                    .font(.title3)
                    .foregroundColor(mealTypeColor)
            }

            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(mealDescription)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label("\(Int(meal.totals.calories)) cal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)

                    if meal.healthScore > 0 {
                        HStack(spacing: 2) {
                            Text("Score:")
                            Text("\(meal.healthScore)/10")
                                .bold()
                        }
                        .font(.caption)
                        .foregroundColor(scoreColor)
                    }
                }
            }

            Spacer()

            // Time
            Text(formattedTime)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    var mealTypeIcon: String {
        switch meal.mealType {
        case .breakfast:
            return "sunrise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.stars.fill"
        case .snack:
            return "leaf.fill"
        }
    }

    var mealTypeColor: Color {
        switch meal.mealType {
        case .breakfast:
            return .orange
        case .lunch:
            return .yellow
        case .dinner:
            return .purple
        case .snack:
            return .green
        }
    }

    var mealDescription: String {
        if meal.foods.count == 1 {
            return meal.foods[0].name
        } else if meal.foods.count == 2 {
            return "\(meal.foods[0].name) & \(meal.foods[1].name)"
        } else {
            return "\(meal.foods[0].name) & \(meal.foods.count - 1) more"
        }
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: meal.timestamp)
    }

    var scoreColor: Color {
        switch meal.healthScore {
        case 8...10:
            return .green
        case 5..<8:
            return .orange
        default:
            return .red
        }
    }
}
