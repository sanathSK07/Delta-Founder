//
//  FoodLogView.swift
//  HealthTracker
//
//  Food logging with photo recognition
//

import SwiftUI
import PhotosUI

struct FoodLogView: View {
    @StateObject private var viewModel = FoodLogViewModel()
    @State private var showAddFood = false

    var body: some View {
        ZStack {
            if viewModel.foodEntries.isEmpty && !viewModel.isLoading {
                EmptyFoodLogView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Daily summary
                        DailySummaryCard(
                            calories: viewModel.totalCaloriesToday,
                            carbs: viewModel.totalCarbsToday,
                            protein: viewModel.totalProteinToday,
                            fat: viewModel.totalFatToday
                        )

                        // Meals by type
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            if let entries = viewModel.entriesByMealType[mealType], !entries.isEmpty {
                                MealSection(mealType: mealType, entries: entries) { entry in
                                    Task {
                                        await viewModel.deleteFoodEntry(entry)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Food Log")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddFood = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodView(viewModel: viewModel)
        }
        .refreshable {
            await viewModel.loadFoodEntries()
        }
    }
}

// MARK: - Empty State

struct EmptyFoodLogView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No meals logged today")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Tap + to add your first meal")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Daily Summary Card

struct DailySummaryCard: View {
    let calories: Double
    let carbs: Double
    let protein: Double
    let fat: Double

    var body: some View {
        VStack(spacing: 12) {
            Text("Today's Nutrition")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                MacroCircle(
                    value: Int(calories),
                    label: "Calories",
                    color: .orange
                )

                MacroCircle(
                    value: Int(carbs),
                    label: "Carbs (g)",
                    color: .blue
                )

                MacroCircle(
                    value: Int(protein),
                    label: "Protein (g)",
                    color: .red
                )

                MacroCircle(
                    value: Int(fat),
                    label: "Fat (g)",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MacroCircle: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Meal Section

struct MealSection: View {
    let mealType: MealType
    let entries: [FoodEntry]
    let onDelete: (FoodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mealType.icon)
                    .foregroundColor(Color(mealType.color))

                Text(mealType.rawValue)
                    .font(.headline)

                Spacer()

                Text("\(Int(entries.reduce(0) { $0 + $1.calories })) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ForEach(entries) { entry in
                FoodEntryRow(entry: entry, onDelete: { onDelete(entry) })
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !entry.macroSummary.isEmpty {
                    Text(entry.macroSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(entry.displayCalories)
                .font(.subheadline)
                .fontWeight(.semibold)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Food View

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var foodName = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var calories: Double = 0
    @State private var carbs: Double = 0
    @State private var protein: Double = 0
    @State private var fat: Double = 0
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    TextField("Food name", text: $foodName)

                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section("Nutrition") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", value: $carbs, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", value: $protein, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", value: $fat, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section("Photo (Optional)") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Add Photo", systemImage: "camera.fill")
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let entry = FoodEntry(
                            name: foodName,
                            mealType: selectedMealType,
                            calories: calories,
                            carbohydrates: carbs,
                            protein: protein,
                            fat: fat
                        )
                        Task {
                            await viewModel.addFoodEntry(entry)
                            dismiss()
                        }
                    }
                    .disabled(foodName.isEmpty || calories == 0)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        FoodLogView()
    }
}
