import Foundation
import SwiftUI
import Combine

final class StreakManager: ObservableObject {
    static let shared = StreakManager()

    private let calendar: Calendar = .current

    // Speicherschlüssel
    private let markedBlueDatesKey = "markedBlueDates" // JSON-Array von Strings (yyyy-MM-dd)
    private let todayFlameDateKey = "todayFlameDate"

    // Persistierte Werte über AppStorage-ähnlichen UserDefaults-Zugriff (außerhalb von Views nutzbar)
    private var defaults: UserDefaults { .standard }

    // MARK: - Persistenz-Wrapper
    private var markedBlueDates: Set<String> {
        get {
            guard let string = defaults.string(forKey: markedBlueDatesKey),
                  let data = string.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return Set(array)
        }
        set {
            let array = Array(newValue)
            if let data = try? JSONEncoder().encode(array),
               let string = String(data: data, encoding: .utf8) {
                defaults.set(string, forKey: markedBlueDatesKey)
            }
            objectWillChange.send()
        }
    }

    private var todayFlameDate: String {
        get { defaults.string(forKey: todayFlameDateKey) ?? "" }
        set { defaults.set(newValue, forKey: todayFlameDateKey); objectWillChange.send() }
    }

    // MARK: - Öffentliche API

    func markTodayCompleted() {
        let today = Date()
        let key = dateKey(today)

        // Flammen-Datum auf heute setzen (für Anzeige eines Badges, falls benötigt)
        todayFlameDate = key

        // Abgeschlossenen Tag speichern
        var set = markedBlueDates
        set.insert(key)
        markedBlueDates = set
    }

    func isDateCompleted(_ date: Date) -> Bool {
        markedBlueDates.contains(dateKey(date))
    }

    // Verzögerte Zurücksetzlogik:
    // - Der Streak repräsentiert aufeinanderfolgende Tage bis zum zuletzt abgeschlossenen Tag
    // - Wenn der gestrige Tag verpasst wurde (Lücke > 1 Tag bis zur letzten Erfassung), dann 0 zurückgeben
    // - Andernfalls rückwärts ab dem zuletzt abgeschlossenen Tag die aufeinanderfolgenden Tage zählen
    func currentStreakCount(referenceDate: Date = Date()) -> Int {
        // Ermittle den zuletzt abgeschlossenen Tag, der <= heute ist
        let latestCompleted = mostRecentCompletedDate(upTo: referenceDate)
        guard let start = latestCompleted else { return 0 }

        // Sicherstellen, dass keine Lücke besteht: Der letzte abgeschlossene Tag muss heute oder gestern sein
        if let daysGap = calendar.dateComponents([.day], from: start.stripTime(using: calendar), to: referenceDate.stripTime(using: calendar)).day, daysGap > 1 {
            return 0
        }

        // Aufeinanderfolgende Tage rückwärts ab Start zählen
        var count = 0
        var cursor = start
        while true {
            if isDateCompleted(cursor) {
                count += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                break
            }
        }
        return count
    }

    // Optional: für UI-Badges, die anzeigen, ob heute abgeschlossen wurde
    func isTodayMarkedComplete() -> Bool {
        let todayKey = dateKey(Date())
        return todayFlameDate == todayKey
    }

    // Hilfsfunktion: ermittelt das zuletzt abgeschlossene Datum bis zu einem Referenzdatum
    private func mostRecentCompletedDate(upTo referenceDate: Date) -> Date? {
        // Schneller Pfad: heute prüfen, dann gestern
        let today = referenceDate.stripTime(using: calendar)
        if isDateCompleted(today) { return today }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), isDateCompleted(yesterday) { return yesterday }

        // Fallback: rückwärts scannen bis zu einem sinnvollen Limit (z. B. 2 Jahre)
        var cursor = today
        for _ in 0..<730 { // ~2 Jahre
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
            if isDateCompleted(cursor) { return cursor }
        }
        return nil
    }

    // MARK: - Hilfsfunktionen
    func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date.stripTime(using: calendar))
    }
}

private extension Date {
    func stripTime(using calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: comps) ?? self
    }
}
