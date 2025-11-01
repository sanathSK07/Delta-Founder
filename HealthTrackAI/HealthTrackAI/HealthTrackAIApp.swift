//
//  HealthTrackAIApp.swift
//  HealthTrackAI
//
//  Main app entry point
//

import SwiftUI
import Firebase

@main
struct HealthTrackAIApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var healthKitManager = HealthKitManager()

    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(healthKitManager)
        }
    }
}
