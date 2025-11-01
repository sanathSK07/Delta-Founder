//
//  ProfileSetupView.swift
//  HealthTrackAI
//
//  User profile setup
//

import SwiftUI

struct ProfileSetupView: View {
    @Binding var profile: UserProfile
    let onContinue: () -> Void

    @State private var heightFeet = 5
    @State private var heightInches = 9
    @State private var weightLbs = 176

    private let dietaryOptions = [
        "None",
        "Vegetarian",
        "Vegan",
        "Gluten-Free",
        "Dairy-Free",
        "Keto",
        "Paleo"
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack(spacing: 8) {
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
            }
            .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Tell us about yourself")
                        .font(.title2)
                        .bold()

                    // Age
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                        TextField("Enter age", value: $profile.age, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                    }

                    // Sex
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sex")
                            .font(.headline)
                        Picker("Sex", selection: $profile.sex) {
                            Text("Male").tag("male")
                            Text("Female").tag("female")
                        }
                        .pickerStyle(.segmented)
                    }

                    // Height
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.headline)
                        HStack {
                            Picker("Feet", selection: $heightFeet) {
                                ForEach(4..<8) { feet in
                                    Text("\(feet)'").tag(feet)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)

                            Picker("Inches", selection: $heightInches) {
                                ForEach(0..<12) { inches in
                                    Text("\(inches)\"").tag(inches)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }
                        .frame(height: 100)
                        .onChange(of: heightFeet) { _ in updateHeightCm() }
                        .onChange(of: heightInches) { _ in updateHeightCm() }
                    }

                    // Weight
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight (lbs)")
                            .font(.headline)
                        TextField("Enter weight", value: $weightLbs, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .onChange(of: weightLbs) { _ in
                                profile.weightKg = Double(weightLbs) * 0.453592
                            }
                    }

                    // Dietary restrictions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dietary Restrictions")
                            .font(.headline)

                        ForEach(dietaryOptions, id: \.self) { option in
                            CheckboxRow(
                                text: option,
                                isSelected: profile.dietaryRestrictions.contains(option),
                                onToggle: {
                                    if profile.dietaryRestrictions.contains(option) {
                                        profile.dietaryRestrictions.removeAll { $0 == option }
                                    } else {
                                        profile.dietaryRestrictions.append(option)
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            updateHeightCm()
        }
    }

    private func updateHeightCm() {
        let totalInches = (heightFeet * 12) + heightInches
        profile.heightCm = Double(totalInches) * 2.54
    }
}
