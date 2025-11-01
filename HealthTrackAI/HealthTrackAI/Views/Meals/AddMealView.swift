//
//  AddMealView.swift
//  HealthTrackAI
//
//  Add meal with photo
//

import SwiftUI
import PhotosUI

struct AddMealView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mealVM: MealViewModel

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var capturedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(12)
                } else {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        VStack(spacing: 16) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)

                            Text("Tap to add meal photo")
                                .font(.headline)

                            Text("AI will identify foods and calculate nutrition")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }

                if mealVM.isAnalyzing {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Analyzing your meal...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                if !mealVM.detectedFoods.isEmpty {
                    FoodConfirmationView(
                        foods: $mealVM.detectedFoods,
                        photo: capturedImage,
                        onConfirm: {
                            Task {
                                await mealVM.saveMeal(photo: capturedImage)
                                dismiss()
                            }
                        }
                    )
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPhoto) { newPhoto in
                Task {
                    if let data = try? await newPhoto?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        capturedImage = image
                        await mealVM.analyzePhoto(image)
                    }
                }
            }
        }
    }
}

struct FoodConfirmationView: View {
    @Binding var foods: [FoodItem]
    let photo: UIImage?
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Is this what you ate?")
                .font(.headline)

            ForEach(foods) { food in
                FoodItemRow(food: food)
            }

            // Totals
            let totals = NutritionTotals.calculate(from: foods)
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("\(Int(totals.calories)) cal")
                    .font(.headline)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            Button(action: onConfirm) {
                Text("Confirm & Log Meal")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct FoodItemRow: View {
    let food: FoodItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.body)

                HStack(spacing: 12) {
                    Label("\(Int(food.calories)) cal", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Text("P: \(Int(food.proteinG))g")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("C: \(Int(food.carbsG))g")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("F: \(Int(food.fatG))g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let confidence = food.confidence {
                    Text("\(Int(confidence * 100))% confident")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Button("Edit") {
                // Show edit sheet
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
