import Foundation
import SwiftUI
import Combine

final class StreakManager: ObservableObject {
    static let shared = StreakManager()

    private let calendar: Calendar = .current

    // Storage keys
    private let markedBlueDatesKey = "markedBlueDates" // JSON array of strings (yyyy-MM-dd)
    private let todayFlameDateKey = "todayFlameDate"

    // Persisted values via AppStorage-like UserDefaults access (usable outside Views)
    private var defaults: UserDefaults { .standard }

    // MARK: - Persistence wrappers
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

    // MARK: - Public API

    func markTodayCompleted() {
        let today = Date()
        let key = dateKey(today)

        // Update flame date to today (for showing badge if needed)
        todayFlameDate = key

        // Persist completed day
        var set = markedBlueDates
        set.insert(key)
        markedBlueDates = set
    }

    func isDateCompleted(_ date: Date) -> Bool {
        markedBlueDates.contains(dateKey(date))
    }

    // Delayed reset semantics:
    // - Streak represents consecutive days up to the most recent completed day
    // - If yesterday was missed (a gap > 1 day to the latest completion), return 0
    // - Otherwise count consecutive backward from the latest completed day
    func currentStreakCount(referenceDate: Date = Date()) -> Int {
        // Find the most recent completed day that is <= today
        let latestCompleted = mostRecentCompletedDate(upTo: referenceDate)
        guard let start = latestCompleted else { return 0 }

        // Ensure there is no gap: latest completed must be either today or yesterday
        if let daysGap = calendar.dateComponents([.day], from: start.stripTime(using: calendar), to: referenceDate.stripTime(using: calendar)).day, daysGap > 1 {
            return 0
        }

        // Count consecutive days backward from start
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

    // Optional: for UI badges that show whether today was completed
    func isTodayMarkedComplete() -> Bool {
        let todayKey = dateKey(Date())
        return todayFlameDate == todayKey
    }

    // Helper to get most recent completed date up to a reference
    private func mostRecentCompletedDate(upTo referenceDate: Date) -> Date? {
        // Fast path: check today, then yesterday
        let today = referenceDate.stripTime(using: calendar)
        if isDateCompleted(today) { return today }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), isDateCompleted(yesterday) { return yesterday }

        // Fallback: scan backwards until a reasonable limit (e.g., 2 years)
        var cursor = today
        for _ in 0..<730 { // ~2 years
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
            if isDateCompleted(cursor) { return cursor }
        }
        return nil
    }

    // MARK: - Utilities
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
