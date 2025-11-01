//
//  GoalsView.swift
//  HealthTrackAI
//
//  Health goals selection
//

import SwiftUI

struct GoalsView: View {
    @Binding var profile: UserProfile
    let onContinue: () -> Void

    private let availableConditions = [
        "Pre-diabetic",
        "Type 2 Diabetes",
        "High Cholesterol",
        "Hypertension",
        "None"
    ]

    private let availableGoals = [
        "Weight Loss",
        "Diabetes Management",
        "Heart Health",
        "General Wellness",
        "Muscle Gain"
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack(spacing: 8) {
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
            }
            .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What brings you here?")
                            .font(.title2)
                            .bold()

                        Text("Select all that apply")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Conditions")
                            .font(.headline)

                        ForEach(availableConditions, id: \.self) { condition in
                            CheckboxRow(
                                text: condition,
                                isSelected: profile.conditions.contains(condition),
                                onToggle: {
                                    if profile.conditions.contains(condition) {
                                        profile.conditions.removeAll { $0 == condition }
                                    } else {
                                        profile.conditions.append(condition)
                                    }
                                }
                            )
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Goals")
                            .font(.headline)

                        ForEach(availableGoals, id: \.self) { goal in
                            CheckboxRow(
                                text: goal,
                                isSelected: profile.goals.contains(goal),
                                onToggle: {
                                    if profile.goals.contains(goal) {
                                        profile.goals.removeAll { $0 == goal }
                                    } else {
                                        profile.goals.append(goal)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding()
            }

            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(profile.goals.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(profile.goals.isEmpty)
            .padding()
        }
    }
}

struct CheckboxRow: View {
    let text: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(text)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
