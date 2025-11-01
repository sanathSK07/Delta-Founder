//
//  SettingsView.swift
//  HealthTracker
//
//  Settings and profile management
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showEditProfile = false
    @State private var showExportConfirmation = false

    var body: some View {
        List {
            // Profile Section
            Section {
                if let user = viewModel.user {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)

                            Text("\(user.age) years old")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("Edit") {
                            showEditProfile = true
                        }
                        .foregroundColor(.blue)
                    }
                }
            } header: {
                Text("Profile")
            }

            // Premium Section
            Section {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)

                    if viewModel.isPremiumUser {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Premium Member")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("All features unlocked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Free Plan")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("Upgrade for AI insights")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("Upgrade") {
                            // Show paywall
                        }
                        .foregroundColor(.blue)
                    }
                }
            } header: {
                Text("Subscription")
            }

            // Notifications Section
            Section {
                Toggle("Enable Reminders", isOn: $viewModel.notificationsEnabled)
                    .onChange(of: viewModel.notificationsEnabled) { _ in
                        viewModel.toggleNotifications()
                    }

                if viewModel.notificationsEnabled {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Text("Customize Reminders")
                    }
                }
            } header: {
                Text("Notifications")
            }

            // HealthKit Section
            Section {
                Toggle("Sync with Health App", isOn: $viewModel.healthKitSyncEnabled)
                    .onChange(of: viewModel.healthKitSyncEnabled) { _ in
                        Task {
                            await viewModel.toggleHealthKitSync()
                        }
                    }
            } header: {
                Text("Health Integration")
            } footer: {
                Text("Sync your health data with Apple Health")
            }

            // Data Section
            Section {
                Button {
                    showExportConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Export Data as PDF")
                    }
                }

                Button(role: .destructive) {
                    // Show confirmation
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete All Data")
                    }
                }
            } header: {
                Text("Data Management")
            }

            // About Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundColor(.secondary)
                }

                NavigationLink("Privacy Policy") {
                    PrivacyPolicyView()
                }

                NavigationLink("Terms of Service") {
                    TermsOfServiceView()
                }

                Button("Contact Support") {
                    // Open email or support
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showEditProfile) {
            if let user = viewModel.user {
                EditProfileView(user: user, viewModel: viewModel)
            }
        }
        .alert("Export Data", isPresented: $showExportConfirmation) {
            Button("Export") {
                Task {
                    await viewModel.exportDataToPDF()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Export your health data as a PDF report")
        }
        .alert("Success", isPresented: $viewModel.showExportSuccess) {
            Button("OK") {}
        } message: {
            Text("Your health data has been exported successfully")
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    let user: User
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var editedUser: User

    init(user: User, viewModel: SettingsViewModel) {
        self.user = user
        self.viewModel = viewModel
        _editedUser = State(initialValue: user)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $editedUser.name)
                    TextField("Age", value: $editedUser.age, format: .number)
                        .keyboardType(.numberPad)
                }

                Section("Physical Info") {
                    HStack {
                        TextField("Weight", value: $editedUser.weight, format: .number)
                            .keyboardType(.decimalPad)

                        Picker("", selection: $editedUser.weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }

                    HStack {
                        TextField("Height", value: $editedUser.height, format: .number)
                            .keyboardType(.decimalPad)

                        Picker("", selection: $editedUser.heightUnit) {
                            ForEach(HeightUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.updateUserProfile(editedUser)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views

struct NotificationSettingsView: View {
    var body: some View {
        List {
            Text("Customize your reminder schedule")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Reminders")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy content goes here")
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service content goes here")
                .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
