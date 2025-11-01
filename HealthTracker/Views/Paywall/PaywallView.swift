//
//  PaywallView.swift
//  HealthTracker
//
//  Subscription paywall with 7-day free trial
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.3), radius: 10)

                        Text("Unlock Premium Features")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("7-day free trial, then $10/month")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    // Features
                    VStack(spacing: 16) {
                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "AI Health Coach",
                            description: "Get personalized insights and recommendations"
                        )

                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Advanced Analytics",
                            description: "View detailed trends and patterns"
                        )

                        FeatureRow(
                            icon: "camera.fill",
                            title: "Food Recognition",
                            description: "Snap photos to log meals instantly"
                        )

                        FeatureRow(
                            icon: "doc.text.fill",
                            title: "PDF Reports",
                            description: "Export your health data anytime"
                        )

                        FeatureRow(
                            icon: "bell.badge.fill",
                            title: "Smart Reminders",
                            description: "Never miss a health check"
                        )

                        FeatureRow(
                            icon: "lock.shield.fill",
                            title: "Secure & Private",
                            description: "Your data stays on your device"
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    // Subscription Options
                    VStack(spacing: 12) {
                        SubscriptionCard(
                            plan: .monthly,
                            isSelected: selectedPlan == .monthly
                        ) {
                            selectedPlan = .monthly
                        }

                        SubscriptionCard(
                            plan: .yearly,
                            isSelected: selectedPlan == .yearly
                        ) {
                            selectedPlan = .yearly
                        }
                    }

                    // Subscribe Button
                    Button {
                        subscribe()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Start 7-Day Free Trial")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                    }
                    .disabled(isProcessing)

                    // Fine Print
                    VStack(spacing: 8) {
                        Text("Cancel anytime. No commitment.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 16) {
                            Button("Terms") {}
                            Button("Privacy") {}
                            Button("Restore") {}
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }

    private func subscribe() {
        isProcessing = true

        // TODO: Integrate with StoreKit 2 for in-app purchases
        // For now, simulate subscription
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPremiumUser = true
            isProcessing = false
            dismiss()
        }
    }
}

// MARK: - Subscription Plan

enum SubscriptionPlan {
    case monthly
    case yearly

    var price: String {
        switch self {
        case .monthly: return "$10"
        case .yearly: return "$99"
        }
    }

    var period: String {
        switch self {
        case .monthly: return "per month"
        case .yearly: return "per year"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "Save 18%"
        }
    }

    var description: String {
        switch self {
        case .monthly: return "Billed monthly"
        case .yearly: return "Billed annually"
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// MARK: - Subscription Card

struct SubscriptionCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.price)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(plan.period)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }

                    Text(plan.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
}
