//
//  NotificationManager.swift
//  HealthTrackAI
//
//  Local notification service
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Daily Reminders

    func scheduleDailyMealReminders() {
        // Clear existing meal reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "breakfast", "lunch", "dinner"
        ])

        // Breakfast reminder (7:30 AM)
        scheduleNotification(
            id: "breakfast",
            title: "Good morning! 🌅",
            body: "Log your breakfast to start your streak",
            hour: 7,
            minute: 30
        )

        // Lunch reminder (12:15 PM)
        scheduleNotification(
            id: "lunch",
            title: "Lunchtime check-in",
            body: "Snap a photo of your meal",
            hour: 12,
            minute: 15
        )

        // Dinner reminder (6:45 PM)
        scheduleNotification(
            id: "dinner",
            title: "How was dinner?",
            body: "Log your meal to keep your HP at 100",
            hour: 18,
            minute: 45
        )
    }

    private func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // MARK: - Instant Alerts

    func sendGlucoseSpikeAlert(value: Double, mealName: String?) {
        let content = UNMutableNotificationContent()
        content.title = "Glucose Spike Detected"

        if let meal = mealName {
            content.body = "Your glucose hit \(Int(value)) mg/dL after eating \(meal). Consider pairing carbs with protein next time."
        } else {
            content.body = "Your glucose reading is \(Int(value)) mg/dL, which is above your target."
        }

        content.sound = .default
        content.categoryIdentifier = "HEALTH_ALERT"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendStreakCelebration(streak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 \(streak)-Day Streak!"

        if streak == 7 {
            content.body = "You've logged every meal this week. You've earned the 'Consistency Champion' trophy!"
        } else if streak == 30 {
            content.body = "30 days of consistency! You're a legend. Keep it going!"
        } else {
            content.body = "You're unstoppable! Keep the momentum going."
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendTrophyUnlock(trophyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Trophy Unlocked!"
        content.body = "You earned '\(trophyName)'. Check your trophy cabinet!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendInactivityNudge(currentSteps: Int, goal: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Only \(currentSteps) steps today!"
        content.body = "A quick 15-min walk would get you closer to your \(goal) step goal 🚶"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "inactivity_nudge",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendMonthlyPlanReady() {
        let content = UNMutableNotificationContent()
        content.title = "Your New Plan is Ready! 📅"
        content.body = "We've adjusted your targets based on last month's progress. Check it out!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Clear Notifications

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
