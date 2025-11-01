//
//  HomeView.swift
//  HealthTrackAI
//
//  Main home screen
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var mealVM = MealViewModel()
    @StateObject private var gamificationVM = GamificationViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // HP Bar
                    HPBarView(currentHP: gamificationVM.healthPoints)

                    // Streak Card
                    StreakCard(streak: gamificationVM.currentStreak)

                    // Daily Summary
                    DailySummaryCard(
                        mealsLogged: mealVM.todayMeals.count,
                        totalCalories: Int(mealVM.todayCalories),
                        calorieGoal: authViewModel.user?.currentPlan?.caloriesPerDay ?? 2000,
                        steps: Int(mealVM.todaySteps),
                        stepGoal: 8000
                    )

                    // Add Meal Button
                    Button(action: {
                        if subscriptionManager.isSubscribed {
                            mealVM.showAddMeal = true
                        } else {
                            // Show paywall
                        }
                    }) {
                        Label("Add Meal Photo", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    // Quick Actions
                    HStack(spacing: 12) {
                        QuickActionButton(
                            icon: "pencil",
                            title: "Manual",
                            action: {
                                // Show manual entry
                            }
                        )

                        QuickActionButton(
                            icon: "drop.fill",
                            title: "Log Glucose",
                            action: {
                                // Show glucose entry
                            }
                        )

                        QuickActionButton(
                            icon: "heart.fill",
                            title: "Log BP",
                            action: {
                                // Show BP entry
                            }
                        )
                    }

                    // Recent Meals
                    if !mealVM.todayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Meals")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(mealVM.todayMeals) { meal in
                                MealCardView(meal: meal)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("HealthTrack AI")
            .sheet(isPresented: $mealVM.showAddMeal) {
                AddMealView()
                    .environmentObject(mealVM)
            }
            .task {
                await mealVM.loadMeals()
                await gamificationVM.loadGamificationData()
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .foregroundColor(.primary)
    }
}
