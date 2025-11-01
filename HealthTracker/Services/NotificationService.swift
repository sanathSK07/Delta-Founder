//
//  NotificationService.swift
//  HealthTracker
//
//  Local notification service for health reminders
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            isAuthorized = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        } catch {
            print("Notification authorization failed: \(error.localizedDescription)")
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Schedule Reminders

    func scheduleReminders() async {
        guard isAuthorized else {
            await requestAuthorization()
            return
        }

        // Cancel existing notifications
        notificationCenter.removeAllPendingNotificationRequests()

        // Schedule daily reminders
        await scheduleMorningBloodSugarReminder()
        await scheduleWaterReminders()
        await scheduleMedicationReminder()
        await scheduleEveningBloodSugarReminder()
        await scheduleActivityReminder()
    }

    // MARK: - Individual Reminders

    private func scheduleMorningBloodSugarReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! 🌅"
        content.body = "Time to check your morning blood sugar level"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "BLOOD_SUGAR_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "morning_blood_sugar",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    private func scheduleEveningBloodSugarReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Evening Check-in ✨"
        content.body = "Don't forget to log your evening blood sugar"
        content.sound = .default
        content.categoryIdentifier = "BLOOD_SUGAR_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "evening_blood_sugar",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    private func scheduleWaterReminders() async {
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated! 💧"
        content.body = "Time for a glass of water"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"

        // Schedule water reminders every 2 hours during the day
        let hours = [9, 11, 13, 15, 17, 19]

        for (index, hour) in hours.enumerated() {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "water_reminder_\(index)",
                content: content,
                trigger: trigger
            )

            try? await notificationCenter.add(request)
        }
    }

    private func scheduleMedicationReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder 💊"
        content.body = "Time to take your medication"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "medication_reminder",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    private func scheduleActivityReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Time to Move! 🚶‍♀️"
        content.body = "A quick 10-minute walk can help manage blood sugar"
        content.sound = .default
        content.categoryIdentifier = "ACTIVITY_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "activity_reminder",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    // MARK: - Cancel Notifications

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Send Immediate Notification

    func sendImmediateNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await notificationCenter.add(request)
    }

    // MARK: - Get Pending Notifications

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}
