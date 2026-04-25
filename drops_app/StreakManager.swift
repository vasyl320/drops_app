import Foundation
import SwiftUI
import Combine

/*
 StreakManager – Verwaltung von Streaks und Tagesmarkierungen
 ------------------------------------------------------------
 Zweck
 - Speichert/liest abgeschlossene Tage ("Ziel erreicht") und liefert daraus den aktuellen Streak.
 - Bietet UI‑Hilfen (z. B. prüfen, ob heute abgeschlossen wurde).

 Persistenz
 - UserDefaults mit zwei Schlüsseln:
   • markedBlueDates: JSON‑Array von yyyy‑MM‑dd‑Strings (abgeschlossene Tage)
   • todayFlameDate: yyyy‑MM‑dd‑String (Badge‑Anzeige für "heute abgeschlossen")

 Architektur
 - Singleton (shared), als ObservableObject nutzbar. Änderungen triggern objectWillChange, damit Views reaktiv aktualisieren.
 - Alle Datumsoperationen verwenden den aktuellen Kalender und die lokale Zeitzone.
*/
final class StreakManager: ObservableObject {
    // MARK: - Singleton & Grundkonfiguration
    static let shared = StreakManager()

    private let calendar: Calendar = .current

    // MARK: - Persistenzschlüssel & Storage
    private let markedBlueDatesKey = "markedBlueDates"   // JSON‑Array von Strings (yyyy‑MM‑dd)
    private let todayFlameDateKey = "todayFlameDate"

    /// Zugriff auf UserDefaults (außerhalb von Views nutzbar)
    private var defaults: UserDefaults { .standard }

    // MARK: - Persistenz‑Wrapper
    /// Menge abgeschlossener Tage als Set der Schlüssel (yyyy‑MM‑dd). Beim Setzen wird ein JSON‑Array gespeichert
    /// und objectWillChange gesendet, damit abhängige Views aktualisieren.
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

    /// Schlüssel des Tages, an dem zuletzt die Flamme für "heute abgeschlossen" gesetzt wurde.
    private var todayFlameDate: String {
        get { defaults.string(forKey: todayFlameDateKey) ?? "" }
        set { defaults.set(newValue, forKey: todayFlameDateKey); objectWillChange.send() }
    }

    // MARK: - Öffentliche API
    /// Markiert den heutigen Tag als abgeschlossen und setzt das Flammen‑Badge.
    func markTodayCompleted() {
        let today = Date()
        let key = dateKey(today)

        // Flammen‑Datum für Badge auf heute setzen
        todayFlameDate = key

        // Abgeschlossenen Tag persistieren
        var set = markedBlueDates
        set.insert(key)
        markedBlueDates = set
    }

    /// Prüft, ob ein bestimmtes Datum als abgeschlossen markiert ist.
    func isDateCompleted(_ date: Date) -> Bool {
        markedBlueDates.contains(dateKey(date))
    }

    /// Ermittelt den aktuellen Streak (aufeinanderfolgende abgeschlossene Tage),
    /// ausgehend vom zuletzt abgeschlossenen Tag bis zum Referenzdatum.
    ///
    /// Regeln:
    /// - Wenn der letzte abgeschlossene Tag weiter als 1 Tag zurückliegt, ist der Streak 0.
    /// - Ansonsten wird rückwärts gezählt, bis ein nicht abgeschlossener Tag gefunden wird.
    func currentStreakCount(referenceDate: Date = Date()) -> Int {
        // Zuletzt abgeschlossenen Tag (<= Referenz) ermitteln
        let latestCompleted = mostRecentCompletedDate(upTo: referenceDate)
        guard let start = latestCompleted else { return 0 }

        // Sicherstellen, dass keine Lücke besteht (heute oder gestern)
        if let daysGap = calendar.dateComponents([.day], from: start.stripTime(using: calendar), to: referenceDate.stripTime(using: calendar)).day, daysGap > 1 {
            return 0
        }

        // Rückwärts aufeinanderfolgende abgeschlossene Tage zählen
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

    /// Gibt zurück, ob "heute" als abgeschlossen markiert ist (für UI‑Badges).
    func isTodayMarkedComplete() -> Bool {
        let todayKey = dateKey(Date())
        return todayFlameDate == todayKey
    }

    // MARK: - Interne Hilfsfunktionen
    /// Liefert das zuletzt abgeschlossene Datum bis einschließlich Referenzdatum.
    /// Schneller Pfad: heute, dann gestern; ansonsten Rückwärtssuche bis zu ~2 Jahren.
    private func mostRecentCompletedDate(upTo referenceDate: Date) -> Date? {
        let today = referenceDate.stripTime(using: calendar)
        if isDateCompleted(today) { return today }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), isDateCompleted(yesterday) { return yesterday }

        var cursor = today
        for _ in 0..<730 { // ~2 Jahre
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
            if isDateCompleted(cursor) { return cursor }
        }
        return nil
    }

    /// Erzeugt den Schlüssel (yyyy‑MM‑dd) für ein Datum. Zeitanteile werden entfernt.
    func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date.stripTime(using: calendar))
    }
}

// MARK: - Date‑Erweiterung
private extension Date {
    /// Entfernt Zeitanteile (setzt auf Mitternacht) gemäß übergebenem Kalender.
    func stripTime(using calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: comps) ?? self
    }
}
