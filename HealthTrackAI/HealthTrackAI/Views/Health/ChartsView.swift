//
//  ChartsView.swift
//  HealthTrackAI
//
//  Health charts and trends
//

import SwiftUI
import Charts

struct ChartsView: View {
    @StateObject private var healthVM = HealthViewModel()
    @State private var selectedPeriod: TimePeriod = .thirtyDays

    enum TimePeriod: String, CaseIterable {
        case sevenDays = "7D"
        case thirtyDays = "30D"
        case ninetyDays = "90D"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period selector
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Health Score
                    HealthScoreCard(score: healthVM.healthScore)

                    // Glucose Chart
                    if !healthVM.glucoseReadings.isEmpty {
                        ChartCard(title: "Glucose Levels") {
                            GlucoseChartView(readings: filteredGlucoseReadings)
                        }
                    }

                    // Weight Chart
                    if !healthVM.weightData.isEmpty {
                        ChartCard(title: "Weight Trend") {
                            WeightChartView(data: healthVM.weightData)
                        }
                    }

                    // Predictions (Premium feature)
                    if !healthVM.predictions.isEmpty {
                        ChartCard(title: "🔮 7-Day Glucose Forecast") {
                            PredictionsChartView(predictions: healthVM.predictions)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Health Trends")
            .task {
                await healthVM.loadAllHealthData()
            }
        }
    }

    var filteredGlucoseReadings: [GlucoseReading] {
        let days = selectedPeriod == .sevenDays ? 7 : (selectedPeriod == .thirtyDays ? 30 : 90)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        return healthVM.glucoseReadings.filter { $0.date >= startDate }
    }
}

struct HealthScoreCard: View {
    let score: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Health Score")
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 20)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: score)

                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                    Text("/100")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(scoreMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    var scoreColor: Color {
        switch score {
        case 70...100:
            return .green
        case 40..<70:
            return .orange
        default:
            return .red
        }
    }

    var scoreMessage: String {
        switch score {
        case 80...100:
            return "Excellent! Your health metrics are on track."
        case 60..<80:
            return "Good progress. Keep up the healthy habits!"
        case 40..<60:
            return "Room for improvement. Focus on consistency."
        default:
            return "Needs attention. Consult your healthcare provider."
        }
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            content
                .frame(height: 200)
                .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct GlucoseChartView: View {
    let readings: [GlucoseReading]

    var body: some View {
        Chart {
            ForEach(readings) { reading in
                LineMark(
                    x: .value("Date", reading.date),
                    y: .value("Glucose", reading.value)
                )
                .foregroundStyle(.blue)

                PointMark(
                    x: .value("Date", reading.date),
                    y: .value("Glucose", reading.value)
                )
                .foregroundStyle(.blue)
            }

            // Target range
            RuleMark(y: .value("Target", 100))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(.green.opacity(0.5))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

struct WeightChartView: View {
    let data: [(date: Date, value: Double)]

    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                LineMark(
                    x: .value("Date", data[index].date),
                    y: .value("Weight", data[index].value)
                )
                .foregroundStyle(.purple)
            }
        }
    }
}

struct PredictionsChartView: View {
    let predictions: [GlucosePrediction]

    var body: some View {
        Chart {
            ForEach(predictions) { prediction in
                // Confidence band
                AreaMark(
                    x: .value("Day", prediction.daysAhead),
                    yStart: .value("Lower", prediction.confidenceLower),
                    yEnd: .value("Upper", prediction.confidenceUpper)
                )
                .foregroundStyle(.blue.opacity(0.2))

                // Prediction line
                LineMark(
                    x: .value("Day", prediction.daysAhead),
                    y: .value("Predicted", prediction.predictedValue)
                )
                .foregroundStyle(.blue)
            }
        }
    }
}
