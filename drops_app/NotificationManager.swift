import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int, interactive: Bool) {
        let center = UNUserNotificationCenter.current()

        // Remove previous pending requests for our identifiers
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder", "dailyReminderNudge"]) 

        // Main daily reminder
        let content = UNMutableNotificationContent()
        content.title = "Zeit zum Trinken"
        content.body = "Bleib hydratisiert und trinke ein Glas Wasser."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        center.add(request)

        // Optional second gentle nudge if interactive mode is enabled
        if interactive {
            let nudgeContent = UNMutableNotificationContent()
            nudgeContent.title = "Sanfte Erinnerung"
            nudgeContent.body = "Wie läuft’s mit dem Trinken heute?"
            nudgeContent.sound = .default

            var nudgeComponents = DateComponents()
            let nudgeHour = (hour + 2) % 24
            nudgeComponents.hour = nudgeHour
            nudgeComponents.minute = minute

            let nudgeTrigger = UNCalendarNotificationTrigger(dateMatching: nudgeComponents, repeats: true)
            let nudgeRequest = UNNotificationRequest(identifier: "dailyReminderNudge", content: nudgeContent, trigger: nudgeTrigger)
            center.add(nudgeRequest)
        }
    }

    static func cancelDailyReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder", "dailyReminderNudge"]) 
    }
}
