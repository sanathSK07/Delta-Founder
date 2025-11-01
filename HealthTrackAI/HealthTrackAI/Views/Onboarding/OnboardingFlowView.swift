//
//  OnboardingFlowView.swift
//  HealthTrackAI
//
//  Onboarding flow coordinator
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentStep = 0
    @State private var userProfile = UserProfile(
        age: 30,
        sex: "male",
        heightCm: 175,
        weightKg: 80,
        conditions: [],
        dietaryRestrictions: [],
        goals: []
    )

    var body: some View {
        ZStack {
            switch currentStep {
            case 0:
                WelcomeView(onContinue: { currentStep = 1 })
            case 1:
                GoalsView(profile: $userProfile, onContinue: { currentStep = 2 })
            case 2:
                ProfileSetupView(profile: $userProfile, onContinue: { currentStep = 3 })
            case 3:
                PermissionsView(profile: $userProfile)
            default:
                WelcomeView(onContinue: { currentStep = 1 })
            }
        }
        .transition(.slide)
        .animation(.easeInOut, value: currentStep)
    }
}

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)

            VStack(spacing: 12) {
                Text("HealthTrack AI")
                    .font(.system(size: 36, weight: .bold))

                Text("Your AI Health Coach in Your Pocket")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "camera.fill", text: "Photo-based food tracking")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Predictive health analytics")
                FeatureRow(icon: "brain.head.profile", text: "AI-personalized plans")
                FeatureRow(icon: "trophy.fill", text: "Gamified progress tracking")
            }
            .padding()

            Spacer()

            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}
