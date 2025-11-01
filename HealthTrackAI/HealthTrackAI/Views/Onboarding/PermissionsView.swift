//
//  PermissionsView.swift
//  HealthTrackAI
//
//  Permissions request screen
//

import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitManager

    @Binding var profile: UserProfile

    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack(spacing: 8) {
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.blue).frame(width: 8, height: 8)
            }
            .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Set up your account")
                            .font(.title2)
                            .bold()

                        Text("Create an account to save your progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Permissions")
                            .font(.headline)

                        PermissionCard(
                            icon: "heart.fill",
                            title: "Apple Health",
                            description: "Sync glucose, steps, sleep for smarter insights",
                            color: .red,
                            action: {
                                Task {
                                    try? await healthKitManager.requestAuthorization()
                                }
                            }
                        )

                        PermissionCard(
                            icon: "bell.fill",
                            title: "Notifications",
                            description: "Get meal reminders and health alerts",
                            color: .orange,
                            action: {
                                Task {
                                    _ = try? await NotificationManager.shared.requestAuthorization()
                                }
                            }
                        )
                    }

                    // Medical Disclaimer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("⚠️ Medical Disclaimer")
                            .font(.headline)

                        Text("HealthTrack AI is for informational purposes only and is not a substitute for professional medical advice. Always consult your physician before making health changes. Not FDA-approved.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }

            Button(action: createAccount) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account & Start")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
            .padding()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func createAccount() {
        Task {
            await authViewModel.signUp(email: email, password: password, profile: profile)

            if authViewModel.isAuthenticated {
                // Request permissions
                try? await healthKitManager.requestAuthorization()
                _ = try? await NotificationManager.shared.requestAuthorization()

                // Schedule notifications
                NotificationManager.shared.scheduleDailyMealReminders()

                authViewModel.completeOnboarding()
            } else if let error = authViewModel.errorMessage {
                alertMessage = error
                showingAlert = true
            }
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
