import Foundation
import UserNotifications

enum NotificationManager {
    /// Fordert die Benachrichtigungsberechtigung an und liefert das Ergebnis im Hauptthread zurück.
    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    /// Plant die tägliche Erinnerung um (hour:minute). Optional wird ein zusätzlicher sanfter Hinweis nach +2 Stunden geplant.
    static func scheduleDailyReminder(hour: Int, minute: Int, interactive: Bool) {
        let center = UNUserNotificationCenter.current()

        // Zuerst alte Requests entfernen, damit wir keine Duplikate erzeugen.
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder", "dailyReminderNudge"]) 

        // Hauptbenachrichtigung
        let content = UNMutableNotificationContent()
        content.title = "Zeit zum Trinken"
        content.body = "Stay Hydrated !"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        center.add(request)

        // Optionale zweite Benachrichtigung (sanfter Nudge)
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

    /// Hebt alle geplanten täglichen Erinnerungen auf (Haupt- und Nudge‑Benachrichtigung).
    static func cancelDailyReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder", "dailyReminderNudge"]) 
    }
}
