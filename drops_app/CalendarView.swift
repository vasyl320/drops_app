import SwiftUI
import Foundation

/*
 CalendarView – Monatsübersicht mit Streak-/Erfolgsmarkierungen
 --------------------------------------------------------------
 Zweck
 - Zeigt einen Monatskalender, in dem abgeschlossene Tage (Ziel erreicht) markiert werden.
 - Visualisiert den aktuellen Streak (aufeinanderfolgende abgeschlossene Tage) mit einem zentralen Flammen‑Badge.

 Daten & Zustände
 - Verwendet einen geteilten StreakManager (Singleton) als @StateObject, um Markierungen reaktiv zu beobachten.
 - Hält den aktuell angezeigten Monat (displayedMonth) und eine optionale Datumsauswahl (selectedDate).
 - Nutzt das aktuelle Calendar‑Objekt für Berechnungen (Monatsraster, Wochentage, usw.).
 - Beobachtet die scenePhase, um bei Rückkehr in die App Datumswechsel robust zu behandeln.
 - Speichert lastDay für die Streak‑Berechnung am jeweiligen Tag.

 Interaktion
 - Pfeil‑Buttons im Kopf wechseln den Monat.
 - Ein Tipp auf ein Tagesfeld wählt dieses aus (nur UI‑Markierung, kein Seiteneffekt).
 - Wenn der Nutzer in der Zähleransicht das Tagesziel erreicht, markiert StreakManager den Tag. Diese Markierung
   wird hier gelesen und als Flamme im Tagesfeld angezeigt.

 Gestaltung & Barrierefreiheit
 - „Meer‑Stil“: Blau/Cyan/Teal‑Verläufe, weiche Schatten.
 - Klare Typografie, große Touch‑Ziele, semantische Labels für VoiceOver.
 - Heute und Auswahlzustände werden visuell hervorgehoben (Rahmen/Schattierung).
*/
struct CalendarView: View {
    // MARK: - Zustände & Umgebungen

    /// Reaktives Modell, das die abgeschlossenen Tage und den Streak verwaltet.
    @StateObject private var streakManager = StreakManager.shared

    /// Der aktuell im Kalender angezeigte Monat (Startwert: heute).
    @State private var displayedMonth: Date = Date()

    /// Das vom Nutzer aktuell ausgewählte Datum (nur UI‑Auswahl, optional).
    @State private var selectedDate: Date? = nil

    /// Kalenderinstanz für Datumsberechnungen (Wochentage, Monatsraster, etc.).
    private let calendar = Calendar.current

    /// Scene‑Phase (active/inactive/background), um auf App‑Statuswechsel zu reagieren.
    @Environment(\.scenePhase) private var scenePhase

    /// Letzter bekannter Tag (für Streak‑Auswertungen und Tageswechsel‑Erkennung).
    @State private var lastDay: Date = Date()

    // MARK: - Layout
    var body: some View {
        VStack(spacing: 16) {
            // Titelzeile über dem Kalender mit markanter, blauer Gestaltung
            Text("Streak-Kalender")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color.blue)
                .kerning(0.5)
                .shadow(color: Color.blue.opacity(0.08), radius: 6, x: 0, y: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)

            // Großes, zentriertes Flammen‑Badge, das den aktuellen Streak visualisiert
            ZStack {
                VStack(spacing: -4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 110, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom)
                        )
                        .saturation(1.0)
                        .brightness(0.08)
                        .shadow(color: Color.cyan.opacity(0.55), radius: 8, x: 0, y: 2)
                        .shadow(color: Color.white.opacity(0.25), radius: 6, x: 0, y: 0)
                        .opacity(1.0)

                    Text("\(currentStreakCount())")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.cyan.opacity(0.45), radius: 8, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.35), radius: 6, x: 0, y: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: -4)
            }
            .frame(width: 180, height: 180)
            .padding(.bottom, 8)
            .accessibilityHidden(true)

            // Kalendercontainer: Kopfzeile, Wochentagszeile, Monatsraster
            VStack(spacing: 20) {
                header
                weekdayHeader
                monthGrid
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding(20)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.08), Color.blue.opacity(0.02)]),
                           startPoint: .top,
                           endPoint: .bottom)
        )
        .navigationBarTitleDisplayMode(.inline)
        // Tageswechsel aus dem System beobachten und den Referenztag aktualisieren
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            lastDay = Date()
        }
        // Bei Rückkehr in die aktive Phase prüfen, ob ein Tag vergangen ist (z. B. App war im Hintergrund)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if !calendar.isDate(lastDay, inSameDayAs: Date()) {
                    lastDay = Date()
                }
            }
        }
    }

    // MARK: - Kopfzeile (Monatsnavigation)
    /// Kopfbereich mit Navigation zum vorherigen/nächsten Monat und Monats-/Jahresanzeige.
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                    )
                    .overlay(
                        Circle().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    )
                    .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Vorheriger Monat")

            Spacer()

            Text(monthTitle(for: displayedMonth) + " " + yearTitle(for: displayedMonth))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.blue)
                .contentTransition(.opacity)

            Spacer()

            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                    )
                    .overlay(
                        Circle().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    )
                    .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Nächster Monat")
        }
    }

    // MARK: - Wochentagskopf (Mo–So)
    /// Zeigt die Kurzbezeichnungen der Wochentage in einer einheitlich gestalteten Kopfzeile.
    private var weekdayHeader: some View {
        let symbols = weekdaySymbolsShort()
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(colors: [Color.blue.opacity(0.35), Color.cyan.opacity(0.35)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                    )
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Monatsraster
    /// Ein 7‑spaltiges Raster, das alle Tage des angezeigten Monats (inkl. Vor-/Nachlauf) anzeigt.
    private var monthGrid: some View {
        let days = daysForMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 7), spacing: 14) {
            ForEach(days, id: \.self) { day in
                dayCell(for: day)
            }
        }
    }

    // MARK: - Tageszelle
    /// Rendert eine einzelne Tageszelle inkl. Auswahlzustand, Markierung und Heutigkeits‑Rahmen.
    /// - Parameter date: Der darzustellende Tag.
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let inMonth = isInDisplayedMonth(date)
        let isToday = self.isToday(date)
        let isSelected = (selectedDate == date)
        let isMarked = streakManager.isDateCompleted(date)

        let base = ZStack {
            // Hintergrund hängt davon ab, ob der Tag im aktuellen Monat liegt und ob er ausgewählt ist.
            DayBackground(inMonth: inMonth, isSelected: isSelected)

            // Zarte Wasserwellen‑Note im Hintergrund für optische Struktur.
            Image(systemName: "water.waves")
                .font(.system(size: 42, weight: .regular))
                .foregroundColor(.white.opacity(inMonth ? 0.06 : 0.0))
                .rotationEffect(.degrees(8))
                .offset(x: 6, y: -6)
                .allowsHitTesting(false)

            // Markierungslogik: Abgeschlossene Tage zeigen eine Flamme; sonst Tageszahl.
            if isMarked || (isToday && streakManager.isTodayMarkedComplete()) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color.cyan.opacity(0.35), radius: 2, x: 0, y: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            } else {
                Text(dayLabel(for: date))
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(inMonth ? Color.primary : Color.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }

        base
            .aspectRatio(1.0, contentMode: .fit)
            .padding(5)
            // Rahmen für Auswahl bzw. für „heute“; verleiht Klarheit ohne harte Füllung.
            .overlay(
                selectionOrTodayStroke(isSelected: isSelected, isToday: isToday)
            )
            .shadow(color: isToday ? Color.cyan.opacity(0.25) : Color.clear, radius: 6, x: 0, y: 2)
            .onTapGesture { selectedDate = date }
            .contentShape(Rectangle())
            .accessibilityLabel(accessibilityLabel(for: date))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Hintergrund für Tageszellen
    /// Hintergrunddarstellung eines Tagesfeldes. Innerhalb des Monats erscheint ein zarter Farbverlauf,
    /// außerhalb bleibt der Hintergrund transparent. Bei Auswahl wird die Intensität erhöht.
    private struct DayBackground: View {
        let inMonth: Bool
        let isSelected: Bool

        var body: some View {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundStyle)
        }

        /// Liefert den passenden Füllstil je nach Zustand.
        private var backgroundStyle: AnyShapeStyle {
            if inMonth {
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(isSelected ? 0.28 : 0.12),
                            Color.cyan.opacity(isSelected ? 0.28 : 0.12),
                            Color.teal.opacity(isSelected ? 0.28 : 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            } else {
                return AnyShapeStyle(
                    LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
        }
    }

    // MARK: - Rahmenlogik (Auswahl/Heute)
    /// Zeichnet je nach Zustand einen Rahmen: kräftiger bei Auswahl, blau/cyan bei „heute“.
    @ViewBuilder
    private func selectionOrTodayStroke(isSelected: Bool, isToday: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    lineWidth: 2.5
                )
        } else if isToday {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.9)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    lineWidth: 2
                )
        } else {
            EmptyView()
        }
    }

    // MARK: - Navigation & Datumsberechnung
    /// Verschiebt den angezeigten Monat um den angegebenen Offset (negativ = zurück, positiv = vor).
    private func changeMonth(by offset: Int) {
        if let newDate = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                displayedMonth = newDate
            }
        }
    }

    /// Springt animiert auf den aktuellen Monat (heutiges Datum).
    private func jumpToToday() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            displayedMonth = Date()
        }
    }

    /// Formatiert den Monatsnamen (z. B. „Januar“).
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL" // ganzer Monatsname
        return formatter.string(from: startOfMonth(for: date)).capitalized
    }

    /// Formatiert die Jahreszahl (z. B. „2026“).
    private func yearTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy"
        return formatter.string(from: startOfMonth(for: date))
    }

    /// Liefert eine Wochenbeschreibung (z. B. „29. Jan – 4. Feb 2026"); aktuell nur als Beispiel/Helfer vorhanden.
    private func weekTitle(for date: Date) -> String {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return "" }
        let start = interval.start
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start

        let dayMonthFormatter = DateFormatter()
        dayMonthFormatter.calendar = calendar
        dayMonthFormatter.locale = Locale.current
        dayMonthFormatter.dateFormat = "d. MMM"

        let yearFormatter = DateFormatter()
        yearFormatter.calendar = calendar
        yearFormatter.locale = Locale.current
        yearFormatter.dateFormat = "yyyy"

        let startStr = dayMonthFormatter.string(from: start)
        let endStr = dayMonthFormatter.string(from: end)
        let yearStr = yearFormatter.string(from: end)
        return "\(startStr) – \(endStr) \(yearStr)"
    }

    /// Liefert die zwei‑buchstabigen Kurzformen der Wochentage in lokaler Reihenfolge unter Berücksichtigung des ersten Wochentags.
    private func weekdaySymbolsShort() -> [String] {
        var symbols = calendar.shortStandaloneWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        if firstWeekdayIndex > 0 {
            let head = symbols[firstWeekdayIndex...]
            let tail = symbols[..<firstWeekdayIndex]
            symbols = Array(head) + Array(tail)
        }
        return symbols.map { String($0.prefix(2)) }
    }

    /// Ermittelt den Monatsanfang für ein gegebenes Datum.
    private func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    /// Erzeugt das vollständige Gitter an Datumswerten für den angezeigten Monat inkl. Vor‑ und Nachlauf.
    private func daysForMonth() -> [Date] {
        let start = startOfMonth(for: displayedMonth)
        guard let range = calendar.range(of: .day, in: .month, for: start) else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: start)
        let firstWeekday = calendar.firstWeekday
        let leading = (weekdayOfFirst - firstWeekday + 7) % 7

        var days: [Date] = []

        if let startOfGrid = calendar.date(byAdding: .day, value: -leading, to: start) {
            let totalCells = leading + range.count
            let trailing = (7 - (totalCells % 7)) % 7
            let total = totalCells + trailing

            for i in 0..<total {
                if let date = calendar.date(byAdding: .day, value: i, to: startOfGrid) {
                    days.append(date)
                }
            }
        }
        return days
    }

    /// Prüft, ob ein Datum im aktuell angezeigten Monat liegt.
    private func isInDisplayedMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
    }

    /// Prüft, ob ein Datum „heute“ ist.
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    /// Liefert die Tageszahl als String (z. B. "17").
    private func dayLabel(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }

    /// Liefert ein ausführliches Datum für VoiceOver (z. B. "Dienstag, 17. Januar 2026").
    private func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    /// Aktueller Streak‑Zähler, relativ zu lastDay.
    private func currentStreakCount() -> Int {
        streakManager.currentStreakCount(referenceDate: lastDay)
    }
}

// MARK: - Vorschau
#Preview {
    NavigationStack {
        CalendarView().tint(.blue)
    }
}

