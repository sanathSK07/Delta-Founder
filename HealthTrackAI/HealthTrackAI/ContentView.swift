//
//  ContentView.swift
//  HealthTrackAI
//
//  Root navigation view
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else if !authViewModel.hasCompletedOnboarding {
                OnboardingFlowView()
            } else {
                AuthenticationView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ChartsView()
                .tabItem {
                    Label("Health", systemImage: "chart.line.uptrend.xyaxis")
                }

            MonthlyPlanView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }

            TrophyCabinetView()
                .tabItem {
                    Label("Trophies", systemImage: "trophy.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
