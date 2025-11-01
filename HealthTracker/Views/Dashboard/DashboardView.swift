//
//  DashboardView.swift
//  HealthTracker
//
//  Main dashboard with health metric cards
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.greeting)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Text("Health Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\(viewModel.healthScore)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(healthScoreColor)

                            Text("/ 100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    ProgressView(value: Double(viewModel.healthScore) / 100.0)
                        .tint(healthScoreColor)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)

                // Quick Actions
                QuickActionsView()

                // Health Metrics Grid
                VStack(spacing: 16) {
                    Text("Your Health Metrics")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        BloodSugarCard(bloodSugar: viewModel.latestBloodSugar)
                        BloodPressureCard(bloodPressure: viewModel.latestBloodPressure)
                        CholesterolCard(cholesterol: viewModel.latestCholesterol)
                        StepsCard(steps: viewModel.todaySteps)
                        SleepCard(sleep: viewModel.lastNightSleep)
                        CaloriesCard(calories: viewModel.todayCalories)
                    }
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var healthScoreColor: Color {
        switch viewModel.healthScore {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Quick Actions

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "drop.fill",
                        title: "Log Blood Sugar",
                        color: .red
                    ) {
                        // Navigate to log entry
                    }

                    QuickActionButton(
                        icon: "heart.fill",
                        title: "Log Blood Pressure",
                        color: .pink
                    ) {
                        // Navigate to log entry
                    }

                    QuickActionButton(
                        icon: "fork.knife",
                        title: "Log Meal",
                        color: .orange
                    ) {
                        // Navigate to food log
                    }

                    QuickActionButton(
                        icon: "figure.walk",
                        title: "Log Exercise",
                        color: .green
                    ) {
                        // Navigate to exercise log
                    }
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .clipShape(Circle())

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100)
        }
    }
}

// MARK: - Calories Card

struct CaloriesCard: View {
    let calories: Double

    var body: some View {
        MetricCard(
            icon: "flame.fill",
            title: "Calories",
            value: String(format: "%.0f", calories),
            unit: "kcal",
            color: .orange,
            status: nil
        )
    }
}

#Preview {
    NavigationView {
        DashboardView()
    }
}
