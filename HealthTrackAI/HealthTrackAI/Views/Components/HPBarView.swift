//
//  HPBarView.swift
//  HealthTrackAI
//
//  Health Points bar component
//

import SwiftUI

struct HPBarView: View {
    let currentHP: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Health Points")
                    .font(.headline)
                Spacer()
                Text("\(currentHP)/100")
                    .font(.title2)
                    .bold()
                    .foregroundColor(hpColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 20)

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(hpColor)
                        .frame(width: geometry.size.width * CGFloat(currentHP) / 100, height: 20)
                        .animation(.spring(), value: currentHP)
                }
            }
            .frame(height: 20)

            Text(hpMessage)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    var hpColor: Color {
        switch currentHP {
        case 70...100:
            return .green
        case 40..<70:
            return .orange
        default:
            return .red
        }
    }

    var hpMessage: String {
        switch currentHP {
        case 80...100:
            return "Excellent! You're crushing it today! 💪"
        case 60..<80:
            return "Good work! Keep logging meals to boost your HP."
        case 40..<60:
            return "Getting low. Log your meals and stay active!"
        default:
            return "Critical! Take action to improve your health score."
        }
    }
}
