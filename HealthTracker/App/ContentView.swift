//
//  ContentView.swift
//  HealthTracker
//
//  Main tab bar navigation container
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("isPremiumUser") private var isPremiumUser = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "heart.fill")
            }
            .tag(0)

            // Food Log Tab
            NavigationView {
                FoodLogView()
            }
            .tabItem {
                Label("Food", systemImage: "fork.knife")
            }
            .tag(1)

            // Charts Tab
            NavigationView {
                ChartsView()
            }
            .tabItem {
                Label("Charts", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(2)

            // AI Chat Tab
            NavigationView {
                AIChatView()
            }
            .tabItem {
                Label("AI Coach", systemImage: "message.fill")
            }
            .tag(3)

            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
