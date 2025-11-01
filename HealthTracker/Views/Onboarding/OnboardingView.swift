//
//  OnboardingView.swift
//  HealthTracker
//
//  Multi-step onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: viewModel.progressPercentage)
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top, 20)

                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStep(viewModel: viewModel)
                        .tag(0)

                    BasicInfoStep(viewModel: viewModel)
                        .tag(1)

                    ConditionsStep(viewModel: viewModel)
                        .tag(2)

                    GoalsStep(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation buttons
                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 {
                        Button {
                            withAnimation {
                                viewModel.previousStep()
                            }
                        } label: {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }

                    Button {
                        if viewModel.currentStep < viewModel.totalSteps - 1 {
                            withAnimation {
                                viewModel.nextStep()
                            }
                        } else {
                            Task {
                                await viewModel.completeOnboarding()
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.currentStep < viewModel.totalSteps - 1 ? "Next" : "Get Started")
                                .font(.headline)

                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canProceedFromStep ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canProceedFromStep || viewModel.isLoading)
                }
                .padding()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Step 1: Welcome

struct WelcomeStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue, .red)
                .padding(.top, 40)

            Text("Welcome to HealthTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Your personal health companion for managing diabetes, cholesterol, blood pressure, and overall wellness")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                Text("What's your name?")
                    .font(.headline)

                TextField("Enter your name", text: $viewModel.user.name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Step 2: Basic Info

struct BasicInfoStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tell us about yourself")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    // Age
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                        TextField("Enter your age", value: $viewModel.user.age, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Weight
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.headline)
                        HStack {
                            TextField("Enter weight", value: $viewModel.user.weight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            Picker("Unit", selection: $viewModel.user.weightUnit) {
                                ForEach(WeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                    }

                    // Height
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.headline)
                        HStack {
                            TextField("Enter height", value: $viewModel.user.height, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            Picker("Unit", selection: $viewModel.user.heightUnit) {
                                ForEach(HeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Step 3: Health Conditions

struct ConditionsStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Health Conditions")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Select any that apply (optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(HealthCondition.allCases, id: \.self) { condition in
                        ConditionCard(
                            condition: condition,
                            isSelected: viewModel.selectedConditions.contains(condition)
                        ) {
                            if viewModel.selectedConditions.contains(condition) {
                                viewModel.selectedConditions.remove(condition)
                            } else {
                                viewModel.selectedConditions.insert(condition)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ConditionCard: View {
    let condition: HealthCondition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: condition.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(condition.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Step 4: Goals

struct GoalsStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Your Health Goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("What would you like to achieve?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(HealthGoal.allCases, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: viewModel.selectedGoals.contains(goal)
                        ) {
                            if viewModel.selectedGoals.contains(goal) {
                                viewModel.selectedGoals.remove(goal)
                            } else {
                                viewModel.selectedGoals.insert(goal)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct GoalCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goal.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .green)

                Text(goal.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.green : Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    OnboardingView()
}
