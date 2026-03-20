// CalendarView: Monatsübersicht mit Streak-/Erfolgsmarkierungen
// - Markiert abgeschlossene Tage blau
// - Zeigt eine Flammen-Badge für den heutigen Abschluss
import SwiftUI

struct CalendarView: View {
    // Aktuell angezeigter Monat im Kalender
    @State private var displayedMonth: Date = Date()
    // Vom Nutzer ausgewähltes Datum
    @State private var selectedDate: Date? = nil
    private let calendar = Calendar.current
    
    // Speichert, ob der heutige Tag abgeschlossen ist (für die Flammenanzeige)
    @AppStorage("todayFlameDate") private var todayFlameDate: String = ""

    // Persistente Menge markierter Tage (als JSON-Array gespeichert)
    @AppStorage("markedBlueDates") private var markedBlueDatesStorage: String = "[]" // JSON array of strings (yyyy-MM-dd)

    private var markedBlueDates: Set<String> {
        get {
            if let data = markedBlueDatesStorage.data(using: .utf8),
               let array = try? JSONDecoder().decode([String].self, from: data) {
                return Set(array)
            }
            return []
        }
        nonmutating set {
            let array = Array(newValue)
            if let data = try? JSONEncoder().encode(array),
               let string = String(data: data, encoding: .utf8) {
                markedBlueDatesStorage = string
            }
        }
    }

    // Markiert den heutigen Tag als abgeschlossen (setzt Flamme und blauen Marker)
    func markTodayAsCompleted() {
        // Set today's flame date so the flame shows "1" and persist the mark
        let today = Date()
        let key = dateKey(today)

        // Update the flame date storage for today
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        todayFlameDate = formatter.string(from: today)

        // Persist the blue mark for today
        var set = markedBlueDates
        set.insert(key)
        markedBlueDates = set
    }

    // Öffentliche Helferfunktion: bei Zielerreichung aufrufen
    func userReachedTenOutOfTenToday() {
        // Debounce: if already marked for today, do nothing
        if isTodayMarkedComplete() { return }
        markTodayAsCompleted()
    }

    // Setzt Flamme und Markierungen zurück, wenn ein Tag verpasst wurde
    func resetAllProgressDueToMissedDay() {
        // Clear the flame indicator (so the badge shows 0)
        todayFlameDate = ""
        // Clear all marked blue dates
        markedBlueDates = []
    }

    // Reagiert auf Tageswechsel und setzt ggf. Fortschritt zurück
    func handleDayRollover(previousDayCompleted: Bool) {
        // If the previous day was not completed, reset everything
        if !previousDayCompleted {
            resetAllProgressDueToMissedDay()
        }
    }

    // Prüft, ob ein Datum als abgeschlossen markiert ist
    private func isMarkedBlue(_ date: Date) -> Bool {
        markedBlueDates.contains(dateKey(date))
    }

    // Liefert einen stabilen Schlüssel (yyyy-MM-dd) für ein Datum
    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 16) {
            // External app name/title above the calendar
            Text("Streak-Kalender")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color.blue)
                .kerning(0.5)
                .shadow(color: Color.blue.opacity(0.08), radius: 6, x: 0, y: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            
            // Large centered "fire in sea" badge
            ZStack {
                // Minimal, clean flame without background fill
                ZStack {
                    // Subtle ring (no solid background)
                    Circle()
                        .stroke(
                            LinearGradient(colors: [Color.cyan.opacity(0.6), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                        .shadow(color: Color.cyan.opacity(0.25), radius: 6, x: 0, y: 2)

                    // Soft glow (very light)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan.opacity(0.20),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: 120
                            )
                        )
                        .blendMode(.plusLighter)

                    // Flame icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: Color.cyan.opacity(0.5), radius: 6, x: 0, y: 2)
                        .opacity(0.95)

                    Text("\(currentStreakCount())")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.blue.opacity(0.35), radius: 5, x: 0, y: 2)
                }
            }
            .frame(width: 180, height: 180)
            .padding(.bottom, 8)
            .accessibilityHidden(true)

            // Existing calendar stack
            VStack(spacing: 20) {
                header
                weekdayHeader
                monthGrid
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding(20)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.08), Color.blue.opacity(0.02)]), startPoint: .top, endPoint: .bottom))
        .navigationBarTitleDisplayMode(.inline)
    }

    // Kopfbereich mit Monatsnavigation
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
                        Image(systemName: "water.waves")
                            .font(.system(size: 44, weight: .regular))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 4, y: -4)
                            .clipShape(Circle())
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
                        Image(systemName: "water.waves")
                            .font(.system(size: 44, weight: .regular))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 4, y: -4)
                            .clipShape(Circle())
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

    // Wochentags-Kopfzeile (Mo–So)
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

    // Monatsraster mit Tagen
    private var monthGrid: some View {
        let days = daysForMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 7), spacing: 14) {
            ForEach(days, id: \.self) { day in
                dayCell(for: day)
            }
        }
    }

    // Einzelnes Tagesfeld mit Auswahl-/Markierungslogik
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let inMonth = isInDisplayedMonth(date)
        let isToday = self.isToday(date)

        let isSelected = (selectedDate == date)
        let isMarked = isMarkedBlue(date)

        let base = ZStack {
            DayBackground(inMonth: inMonth, isSelected: isSelected)

            Image(systemName: "water.waves")
                .font(.system(size: 42, weight: .regular))
                .foregroundColor(.white.opacity(inMonth ? 0.06 : 0.0))
                .rotationEffect(.degrees(8))
                .offset(x: 6, y: -6)
                .allowsHitTesting(false)

            if isMarked || (isToday && isTodayMarkedComplete()) {
                // Completed: show centered flame only (no background)
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

            // Removed the blue highlight overlays for completed days
            
        }

        base
            .aspectRatio(1.0, contentMode: .fit)
            .padding(5)
            .overlay(
                selectionOrTodayStroke(isSelected: isSelected, isToday: isToday)
            )
            .shadow(color: isToday ? Color.cyan.opacity(0.25) : Color.clear, radius: 6, x: 0, y: 2)
            .onTapGesture { selectedDate = date }
            .contentShape(Rectangle())
            .accessibilityLabel(accessibilityLabel(for: date))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // Hintergrunddarstellung eines Tagesfeldes (abhängig von Zustand)
    private struct DayBackground: View {
        let inMonth: Bool
        let isSelected: Bool

        var body: some View {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundStyle)
        }

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

    // Rahmen je nach Zustand (ausgewählt/heute)
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

    // Hilfsfunktion: Monat wechseln
    private func changeMonth(by offset: Int) {
        if let newDate = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                displayedMonth = newDate
            }
        }
    }
    
    // Hilfsfunktion: Zu heute springen
    private func jumpToToday() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            displayedMonth = Date()
        }
    }

    // Hilfsfunktion: Monatstitel
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL" // Full month name
        return formatter.string(from: startOfMonth(for: date)).capitalized
    }

    // Hilfsfunktion: Jahrestitel
    private func yearTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy"
        return formatter.string(from: startOfMonth(for: date))
    }

    // Hilfsfunktion: Kurze Wochentagssymbole
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

    // Hilfsfunktion: Monatserster
    private func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    // Hilfsfunktion: Tage des Monats
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

    // Hilfsfunktion: Datum liegt im angezeigten Monat?
    private func isInDisplayedMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
    }

    // Hilfsfunktion: Ist heute?
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    // Hilfsfunktion: Tageszahl-Label
    private func dayLabel(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }

    // Hilfsfunktion: Accessibility-Label
    private func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    // Hilfsfunktion: Ist der heutige Tag abgeschlossen?
    private func isTodayMarkedComplete() -> Bool {
        guard !todayFlameDate.isEmpty else { return false }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        return todayFlameDate == todayString
    }
    
    // Hilfsfunktion: Aktuelle Streak-Länge (aufeinanderfolgende abgeschlossene Tage bis heute)
    private func currentStreakCount() -> Int {
        var count = 0
        var cursor = Date()
        while true {
            let key = dateKey(cursor)
            if markedBlueDates.contains(key) {
                count += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                break
            }
        }
        return count
    }
}

#Preview {
    NavigationStack {
        CalendarView().tint(.blue)
    }
}

