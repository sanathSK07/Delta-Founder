//
//  AIService.swift
//  HealthTracker
//
//  AI-powered chat coach and food recognition
//  Placeholder for OpenAI or similar API integration
//

import Foundation
import UIKit

struct RecognizedFood {
    let name: String
    let calories: Double
    let carbs: Double?
    let protein: Double?
    let fat: Double?
}

class AIService: ObservableObject {
    static let shared = AIService()

    private init() {}

    // MARK: - Chat Coach

    /// Get AI chat response based on user message and health context
    /// - Parameters:
    ///   - message: User's message
    ///   - context: Health context (recent metrics, user profile)
    /// - Returns: AI-generated response
    func getChatResponse(message: String, context: String) async throws -> String {
        // TODO: Integrate with OpenAI API or similar
        // For now, return mock responses

        let lowercaseMessage = message.lowercased()

        if lowercaseMessage.contains("blood sugar") || lowercaseMessage.contains("glucose") {
            return """
            Based on your recent blood sugar readings, you're doing great! Here are some tips to maintain healthy levels:

            • Eat regular, balanced meals throughout the day
            • Include fiber-rich foods like vegetables and whole grains
            • Stay hydrated with water
            • Take a 10-minute walk after meals

            Remember, consistency is key! Keep tracking your readings so we can spot patterns together.
            """
        } else if lowercaseMessage.contains("blood pressure") {
            return """
            Let's work on maintaining healthy blood pressure together! Here are evidence-based strategies:

            • Reduce sodium intake (aim for less than 2,300mg/day)
            • Eat potassium-rich foods like bananas and sweet potatoes
            • Practice stress-reduction techniques like deep breathing
            • Aim for 30 minutes of moderate exercise most days

            You've got this! Small, consistent changes make a big difference.
            """
        } else if lowercaseMessage.contains("food") || lowercaseMessage.contains("eat") {
            return """
            Great question about nutrition! Here are some diabetes-friendly eating tips:

            • Fill half your plate with non-starchy vegetables
            • Choose whole grains over refined carbs
            • Include lean protein at each meal
            • Watch portion sizes, especially for carbs

            Would you like specific meal ideas? I'm here to help!
            """
        } else if lowercaseMessage.contains("exercise") || lowercaseMessage.contains("workout") {
            return """
            Exercise is wonderful for managing blood sugar and overall health! Here's what I recommend:

            • Start with 10-15 minutes if you're new to exercise
            • Walking is excellent and low-impact
            • Check blood sugar before and after exercise
            • Stay hydrated

            What type of activity sounds enjoyable to you? Finding something you like makes it sustainable!
            """
        } else {
            return """
            I'm here to support you on your health journey! I can help with:

            • Understanding your health metrics
            • Meal planning and nutrition advice
            • Exercise recommendations
            • Habit formation strategies
            • Tracking patterns in your data

            What specific area would you like to focus on today?
            """
        }
    }

    // MARK: - Food Recognition

    /// Recognize food from an image using Vision/ML
    /// - Parameter image: Photo of food
    /// - Returns: Recognized food with nutrition estimates
    func recognizeFood(from image: UIImage) async throws -> RecognizedFood {
        // TODO: Integrate with Vision framework and nutrition API
        // For MVP, this is a placeholder that returns mock data

        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Return mock recognized food
        // In production, this would use CoreML Vision model or cloud API
        return RecognizedFood(
            name: "Mixed Salad",
            calories: 150,
            carbs: 12,
            protein: 8,
            fat: 9
        )
    }

    /// Get nutrition information for a food name
    /// - Parameter foodName: Name of the food
    /// - Returns: Nutrition data
    func getNutritionInfo(for foodName: String) async throws -> RecognizedFood {
        // TODO: Integrate with nutrition database API (e.g., USDA FoodData Central)
        // For MVP, return placeholder data

        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        return RecognizedFood(
            name: foodName,
            calories: 200,
            carbs: 25,
            protein: 10,
            fat: 8
        )
    }

    // MARK: - Health Insights

    /// Generate personalized health insights based on tracked data
    /// - Parameter metrics: Array of health metrics
    /// - Returns: AI-generated insights and recommendations
    func generateInsights(from metrics: [String: Any]) async throws -> String {
        // TODO: Integrate AI model for pattern recognition
        // For MVP, return template-based insights

        return """
        📊 Weekly Health Summary

        Looking at your data from the past week, here's what I noticed:

        ✅ Strengths:
        • Your blood sugar has been stable most days
        • You're consistently hitting your step goals
        • Great job logging meals regularly!

        💡 Opportunities:
        • Try to maintain more consistent meal times
        • Consider adding a short walk after dinner
        • Your sleep could use a boost - aim for 7-8 hours

        🎯 This Week's Goal:
        Let's focus on increasing your fiber intake. Try adding one extra serving of vegetables to your lunch!

        Keep up the amazing work! Consistency beats perfection every time.
        """
    }
}

// MARK: - Errors

enum AIServiceError: Error, LocalizedError {
    case apiKeyMissing
    case requestFailed
    case invalidResponse
    case recognitionFailed

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing: return "API key not configured"
        case .requestFailed: return "Failed to communicate with AI service"
        case .invalidResponse: return "Received invalid response from AI service"
        case .recognitionFailed: return "Failed to recognize food in image"
        }
    }
}
