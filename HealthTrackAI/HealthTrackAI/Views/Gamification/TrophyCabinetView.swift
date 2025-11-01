//
//  TrophyCabinetView.swift
//  HealthTrackAI
//
//  Trophy cabinet view
//

import SwiftUI

struct TrophyCabinetView: View {
    @StateObject private var gamificationVM = GamificationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Level Progress
                    LevelProgressCard(
                        level: gamificationVM.level,
                        xp: gamificationVM.xp,
                        xpForNext: gamificationVM.xpForNextLevel,
                        progress: gamificationVM.xpProgress
                    )

                    // Stats
                    StatsGrid(gamification: gamificationVM)

                    // Unlocked Trophies
                    if !gamificationVM.unlockedTrophies.isEmpty {
                        TrophySection(
                            title: "🏆 Unlocked (\(gamificationVM.unlockedTrophies.count))",
                            trophies: gamificationVM.unlockedTrophies
                        )
                    }

                    // Locked Trophies
                    if !gamificationVM.lockedTrophies.isEmpty {
                        TrophySection(
                            title: "🔒 Locked (\(gamificationVM.lockedTrophies.count))",
                            trophies: gamificationVM.lockedTrophies
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .task {
                await gamificationVM.loadGamificationData()
            }
        }
    }
}

struct LevelProgressCard: View {
    let level: Int
    let xp: Int
    let xpForNext: Int
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(level)")
                        .font(.title)
                        .bold()

                    Text("\(xp) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .bold()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Next Level")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ProgressView(value: progress)
                    .tint(.blue)

                Text("\(xpForNext - xp) XP to Level \(level + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatsGrid: View {
    let gamification: GamificationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(gamification.currentStreak)",
                    label: "Current Streak",
                    color: .orange
                )

                StatCard(
                    icon: "star.fill",
                    value: "\(gamification.longestStreak)",
                    label: "Longest Streak",
                    color: .yellow
                )

                StatCard(
                    icon: "trophy.fill",
                    value: "\(gamification.unlockedTrophies.count)",
                    label: "Trophies",
                    color: .blue
                )

                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(gamification.level)",
                    label: "Level",
                    color: .purple
                )
            }
        }
    }
}

struct StatCard: View {
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
                .font(.title2)
                .bold()

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct TrophySection: View {
    let title: String
    let trophies: [Trophy]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(trophies) { trophy in
                    TrophyCard(trophy: trophy)
                }
            }
        }
    }
}

struct TrophyCard: View {
    let trophy: Trophy

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(trophy.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: trophy.icon)
                    .font(.title)
                    .foregroundColor(trophy.isUnlocked ? .yellow : .gray)
            }

            Text(trophy.name)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)

            Text(trophy.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if !trophy.isUnlocked {
                Text(trophy.requirement)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .opacity(trophy.isUnlocked ? 1 : 0.6)
    }
}
