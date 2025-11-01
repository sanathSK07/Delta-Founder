//
//  AIChatViewModel.swift
//  HealthTracker
//
//  AI Chat Coach with personalized health suggestions
//

import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date

    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPaywall = false

    @AppStorage("isPremiumUser") private var isPremiumUser = false

    private let aiService = AIService.shared
    private let persistenceService = PersistenceService.shared

    // MARK: - Initialization

    init() {
        loadWelcomeMessage()
    }

    // MARK: - Public Methods

    func sendMessage() async {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Check premium status
        if !isPremiumUser {
            showPaywall = true
            return
        }

        let userMessage = ChatMessage(content: currentMessage, isUser: true)
        messages.append(userMessage)

        let messageToSend = currentMessage
        currentMessage = ""

        isLoading = true
        errorMessage = nil

        do {
            // Get AI response based on user's health data
            let healthContext = try await buildHealthContext()
            let response = try await aiService.getChatResponse(
                message: messageToSend,
                context: healthContext
            )

            let aiMessage = ChatMessage(content: response, isUser: false)
            messages.append(aiMessage)

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func clearChat() {
        messages.removeAll()
        loadWelcomeMessage()
    }

    // MARK: - Private Methods

    private func loadWelcomeMessage() {
        let welcomeText = """
        Hi! I'm your AI Health Coach. I'm here to help you achieve your wellness goals with personalized insights and encouragement.

        I can help with:
        • Understanding your health metrics
        • Suggesting healthy habits
        • Recognizing patterns in your data
        • Providing motivation and support

        ⚠️ Important: I'm not a replacement for professional medical advice. Always consult your healthcare provider for medical decisions.

        How can I support you today?
        """

        messages.append(ChatMessage(content: welcomeText, isUser: false))
    }

    private func buildHealthContext() async throws -> String {
        var context = ""

        // Add recent metrics to context
        if let user = try? await persistenceService.loadUser() {
            context += "User profile: \(user.age) years old, conditions: \(user.conditions.map { $0.rawValue }.joined(separator: ", ")).\n"
        }

        if let bs = try? await persistenceService.getLatestBloodSugar() {
            context += "Latest blood sugar: \(bs.displayValue) \(bs.unit.rawValue) - \(bs.status.rawValue).\n"
        }

        if let bp = try? await persistenceService.getLatestBloodPressure() {
            context += "Latest blood pressure: \(bp.displayValue) mmHg - \(bp.status.rawValue).\n"
        }

        // Add more context as needed
        return context
    }
}
