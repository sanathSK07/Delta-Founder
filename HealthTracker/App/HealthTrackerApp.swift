//
//  HealthTrackerApp.swift
//  HealthTracker
//
//  Created by Delta Founder
//  A comprehensive healthcare tracking app for diabetes, cholesterol, BP, and wellness
//

import SwiftUI

@main
struct HealthTrackerApp: App {
    @StateObject private var persistenceService = PersistenceService.shared
    @StateObject private var healthKitService = HealthKitService.shared
    @StateObject private var notificationService = NotificationService.shared

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        // Configure app appearance
        configureAppAppearance()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(persistenceService)
            .environmentObject(healthKitService)
            .environmentObject(notificationService)
        }
    }

    // MARK: - Private Methods

    private func configureAppAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
