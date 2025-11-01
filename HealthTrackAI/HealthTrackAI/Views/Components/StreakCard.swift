//
//  StreakCard.swift
//  HealthTrackAI
//
//  Streak display component
//

import SwiftUI

struct StreakCard: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: streak > 0 ? "flame.fill" : "flame")
                .font(.system(size: 44))
                .foregroundColor(streak > 0 ? .orange : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(streak)-Day Streak")
                    .font(.title2)
                    .bold()

                Text(streakMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if streak >= 7 {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    var streakMessage: String {
        switch streak {
        case 0:
            return "Log a meal today to start your streak!"
        case 1:
            return "Great start! Keep it going tomorrow."
        case 2...6:
            return "You're building momentum! \(7 - streak) more for a trophy."
        case 7:
            return "One week strong! 🎉"
        case 8...29:
            return "Incredible consistency! Keep pushing."
        case 30:
            return "30 days! You're a legend! 🏆"
        default:
            return "Unstoppable! \(streak) days of dedication."
        }
    }
}
