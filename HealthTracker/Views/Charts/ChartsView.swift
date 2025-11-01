//
//  ChartsView.swift
//  HealthTracker
//
//  Health data visualization and trends
//

import SwiftUI
import Charts

struct ChartsView: View {
    @StateObject private var viewModel = ChartsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Metric Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(HealthMetricType.allCases, id: \.self) { metric in
                            MetricChip(
                                metric: metric,
                                isSelected: viewModel.selectedMetric == metric
                            ) {
                                viewModel.changeMetric(metric)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Timeframe Selector
                Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                    ForEach(ChartTimeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedTimeframe) { _ in
                    Task {
                        await viewModel.loadData()
                    }
                }

                // Chart
                if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 300)
                } else {
                    ChartContainer(viewModel: viewModel)
                }

                // Stats Summary
                StatsSummaryView(viewModel: viewModel)

                // Streak Badge
                StreakBadge(days: viewModel.streakDays)
            }
            .padding(.vertical)
        }
        .navigationTitle("Charts & Insights")
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Metric Chip

struct MetricChip: View {
    let metric: HealthMetricType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: metric.icon)
                    .font(.caption)
                Text(metric.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Chart Container

struct ChartContainer: View {
    @ObservedObject var viewModel: ChartsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trend")
                .font(.headline)
                .padding(.horizontal)

            // Placeholder for actual chart
            // In production, use Swift Charts framework
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 250)

                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("Chart visualization")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Integrate with Swift Charts for iOS 16+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Stats Summary

struct StatsSummaryView: View {
    @ObservedObject var viewModel: ChartsViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                StatCard(
                    title: "Average",
                    value: averageValue,
                    icon: "chart.bar.fill",
                    color: .blue
                )

                StatCard(
                    title: "Entries",
                    value: "\(totalEntries)",
                    icon: "list.bullet",
                    color: .green
                )

                StatCard(
                    title: "Streak",
                    value: "\(viewModel.streakDays)",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }

    private var averageValue: String {
        switch viewModel.selectedMetric {
        case .bloodSugar:
            if let avg = viewModel.averageBloodSugar {
                return String(format: "%.0f", avg)
            }
        case .bloodPressure:
            if let avg = viewModel.averageBloodPressure {
                return "\(Int(avg.systolic))/\(Int(avg.diastolic))"
            }
        case .steps:
            if let avg = viewModel.averageSteps {
                return String(format: "%.0f", avg)
            }
        default:
            break
        }
        return "N/A"
    }

    private var totalEntries: Int {
        switch viewModel.selectedMetric {
        case .bloodSugar: return viewModel.bloodSugarData.count
        case .bloodPressure: return viewModel.bloodPressureData.count
        case .cholesterol: return viewModel.cholesterolData.count
        case .steps: return viewModel.stepsData.count
        case .sleep: return viewModel.sleepData.count
        default: return 0
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Streak Badge

struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(days) Day Streak!")
                    .font(.headline)

                Text("Keep logging to maintain your streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.red.opacity(0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        ChartsView()
    }
}
