//
//  MonthlyPlanView.swift
//  HealthTrackAI
//
//  Monthly plan view
//

import SwiftUI

struct MonthlyPlanView: View {
    @StateObject private var planVM = PlanViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let plan = planVM.currentPlan {
                        // Plan Header
                        PlanHeaderCard(plan: plan)

                        // Daily Targets
                        if let targets = planVM.dailyTargets {
                            DailyTargetsCard(targets: targets)
                        }

                        // Adjustments (if any)
                        if let adjustments = plan.adjustments {
                            AdjustmentsCard(adjustments: adjustments)
                        }

                        // Meal Suggestions
                        if !planVM.mealSuggestions.isEmpty {
                            MealSuggestionsSection(suggestions: planVM.mealSuggestions)
                        }
                    } else if planVM.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        EmptyPlanView(onGenerate: {
                            Task {
                                await planVM.generateNewPlan()
                            }
                        })
                    }
                }
                .padding()
            }
            .navigationTitle("Your Plan")
            .task {
                await planVM.loadCurrentPlan()
            }
        }
    }
}

struct PlanHeaderCard: View {
    let plan: MonthlyPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(planMonth)
                        .font(.title3)
                        .bold()

                    Text("Generated \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    var planMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: plan.generatedAt)
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: plan.generatedAt, relativeTo: Date())
    }
}

struct DailyTargetsCard: View {
    let targets: DailyTargets

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Daily Targets")
                .font(.headline)

            HStack(spacing: 20) {
                TargetBadge(
                    icon: "flame.fill",
                    value: "\(targets.caloriesPerDay)",
                    label: "Calories",
                    color: .orange
                )

                TargetBadge(
                    icon: "leaf.fill",
                    value: "\(targets.carbsG)g",
                    label: "Carbs",
                    color: .green
                )
            }

            HStack(spacing: 20) {
                TargetBadge(
                    icon: "tortoise.fill",
                    value: "\(targets.proteinG)g",
                    label: "Protein",
                    color: .blue
                )

                TargetBadge(
                    icon: "drop.fill",
                    value: "\(targets.fatG)g",
                    label: "Fat",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TargetBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .bold()

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AdjustmentsCard: View {
    let adjustments: PlanAdjustments

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)

                Text("Why we adjusted your plan")
                    .font(.headline)
            }

            Text(adjustments.reason)
                .font(.body)
                .foregroundColor(.secondary)

            if adjustments.change != 0 {
                HStack {
                    Text("Calorie change:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(adjustments.change > 0 ? "+" : "")\(adjustments.change) cal/day")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(adjustments.change > 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MealSuggestionsSection: View {
    let suggestions: [MealSuggestion]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🍽️ Suggested Meals This Week")
                .font(.headline)

            ForEach(suggestions) { suggestion in
                MealSuggestionCard(suggestion: suggestion)
            }
        }
    }
}

struct MealSuggestionCard: View {
    let suggestion: MealSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(suggestion.name)
                    .font(.body)
                    .bold()

                Spacer()

                Text("\(suggestion.calories) cal")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
            }

            Text(suggestion.mealType.capitalized)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("💡 \(suggestion.why)")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EmptyPlanView: View {
    let onGenerate: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Plan Yet")
                .font(.title2)
                .bold()

            Text("Generate your personalized monthly plan based on your goals and health data")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onGenerate) {
                Text("Generate Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
