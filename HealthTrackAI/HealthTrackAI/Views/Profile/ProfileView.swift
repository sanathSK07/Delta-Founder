//
//  ProfileView.swift
//  HealthTrackAI
//
//  Profile and settings view
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    @State private var showingSignOutAlert = false

    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    if let user = authViewModel.user {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.email)
                                    .font(.headline)

                                if subscriptionManager.isSubscribed {
                                    Label("Premium", systemImage: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                } else {
                                    Label("Free", systemImage: "circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                // Subscription Section
                Section {
                    if subscriptionManager.isSubscribed {
                        NavigationLink(destination: ManageSubscriptionView()) {
                            Label("Manage Subscription", systemImage: "star.fill")
                        }
                    } else {
                        NavigationLink(destination: PaywallView()) {
                            HStack {
                                Label("Upgrade to Premium", systemImage: "star.fill")
                                    .foregroundColor(.yellow)

                                Spacer()

                                Text("$9.99/mo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Subscription")
                }

                // Health Data Section
                Section {
                    NavigationLink(destination: Text("Health Data Settings")) {
                        Label("Health Data Sync", systemImage: "heart.fill")
                    }

                    NavigationLink(destination: Text("Notification Settings")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                } header: {
                    Text("Preferences")
                }

                // Profile Section
                Section {
                    NavigationLink(destination: Text("Edit Profile")) {
                        Label("Edit Profile", systemImage: "person.fill")
                    }

                    NavigationLink(destination: Text("Goals & Conditions")) {
                        Label("Update Goals", systemImage: "target")
                    }
                } header: {
                    Text("Profile")
                }

                // Legal Section
                Section {
                    NavigationLink(destination: DisclaimerView()) {
                        Label("Medical Disclaimer", systemImage: "exclamationmark.triangle.fill")
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Legal")
                }

                // Sign Out
                Section {
                    Button(action: { showingSignOutAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("⚠️ Medical Disclaimer")
                    .font(.title2)
                    .bold()

                Text("""
                HealthTrack AI is for informational and educational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment.

                Always consult your physician before making changes to your diet, medication, or health routine.

                Our AI predictions are estimates based on patterns and may not be accurate for your individual circumstances. Do not use this app to make emergency medical decisions.

                This app is not FDA-approved and is not intended to diagnose, treat, cure, or prevent any disease.

                If you experience a medical emergency, call 911 or your local emergency number immediately.
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Medical Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ManageSubscriptionView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Label("Active", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                HStack {
                    Text("Plan")
                    Spacer()
                    Text("Premium Monthly")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Price")
                    Spacer()
                    Text("$9.99/month")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Subscription Details")
            }

            Section {
                Button("Cancel Subscription") {
                    // Open App Store subscriptions
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundColor(.red)
            } footer: {
                Text("Manage your subscription through the App Store. Changes will take effect at the end of your current billing period.")
            }
        }
        .navigationTitle("Manage Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var products: [Product] = []
    @State private var isPurchasing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)

                    Text("Upgrade to Premium")
                        .font(.title)
                        .bold()

                    Text("Unlock AI-powered features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    PremiumFeature(icon: "camera.fill", text: "Unlimited photo food tracking")
                    PremiumFeature(icon: "brain.head.profile", text: "AI personalized monthly plans")
                    PremiumFeature(icon: "chart.line.uptrend.xyaxis", text: "7-day health predictions")
                    PremiumFeature(icon: "trophy.fill", text: "Full gamification system")
                    PremiumFeature(icon: "bell.badge.fill", text: "Smart health alerts")
                    PremiumFeature(icon: "doc.text.fill", text: "Export health reports (PDF)")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                // Pricing
                if !products.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(products, id: \.id) { product in
                            PricingCard(product: product) {
                                purchase(product)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }

                // Restore Purchases
                Button("Restore Purchases") {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)

                // Legal
                Text("Auto-renewable. Cancel anytime. By subscribing you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Go Premium")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            products = await subscriptionManager.fetchProducts()
        }
    }

    private func purchase(_ product: Product) {
        guard !isPurchasing else { return }

        isPurchasing = true
        Task {
            do {
                _ = try await subscriptionManager.purchase(product)
            } catch {
                print("Purchase failed: \(error)")
            }
            isPurchasing = false
        }
    }
}

struct PremiumFeature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

struct PricingCard: View {
    let product: Product
    let onPurchase: () -> Void

    var body: some View {
        Button(action: onPurchase) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
    }
}
