import SwiftUI

struct CalendarView: View {
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    private let calendar = Calendar.current

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

    // MARK: - Header with month navigation & Today
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30, weight: .regular))
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
                    .font(.system(size: 30, weight: .regular))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Nächster Monat")

            Spacer()

            Button("Heute") {
                jumpToToday()
            }
            .font(.system(size: 18, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.blue.opacity(0.15)))
            .foregroundStyle(Color.blue)
        }
    }

    // MARK: - Weekday header (Mon-Sun)
    private var weekdayHeader: some View {
        let symbols = weekdaySymbolsShort()
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.blue.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Month grid
    private var monthGrid: some View {
        let days = daysForMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 7), spacing: 14) {
            ForEach(days, id: \.self) { day in
                dayCell(for: day)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: displayedMonth)
    }

    // MARK: - Day cell
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let inMonth = isInDisplayedMonth(date)
        let isToday = self.isToday(date)
        let isInMonth = inMonth

        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(selectedDate == date ? Color.blue.opacity(0.25) : (inMonth ? Color.blue.opacity(0.10) : Color.clear))
            Text(dayLabel(for: date))
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(inMonth ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .padding(5)
        .overlay(
            Group {
                if selectedDate == date {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue, lineWidth: 2.5)
                } else if isToday {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue.opacity(0.9), lineWidth: 2)
                }
            }
        )
        .shadow(color: isToday ? Color.blue.opacity(0.15) : Color.clear, radius: 4, x: 0, y: 1)
        .onTapGesture {
            selectedDate = date
        }
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel(for: date))
        .accessibilityAddTraits(selectedDate == date ? .isSelected : [])
    }

    // MARK: - Helpers
    private func changeMonth(by offset: Int) {
        if let newDate = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                displayedMonth = newDate
            }
        }
    }

    private func jumpToToday() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            displayedMonth = Date()
        }
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL" // Full month name
        return formatter.string(from: startOfMonth(for: date)).capitalized
    }

    private func yearTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy"
        return formatter.string(from: startOfMonth(for: date))
    }

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

    private func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

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

    private func isInDisplayedMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func dayLabel(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }

    private func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        CalendarView().tint(.blue)
    }
}

