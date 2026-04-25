import SwiftUI

/*
 ReminderSettingsView – Einstellungen für tägliche Erinnerungen
 --------------------------------------------------------------
 Zweck
 - Nutzer kann tägliche Erinnerungen aktivieren und konfigurieren.
 - Unterstützt zwei Modi: feste Erinnerung (Zeitpunkt) und interaktive Erinnerung.
 - Planung/Kündigung von Benachrichtigungen erfolgt über NotificationManager.

 Daten & Zustände
 - reminderEnabled: fester Alarm an/aus
 - reminderInteractive: interaktiver Hinweis an/aus (schließt festen Alarm aus)
 - reminderHour/minute: gewählte Uhrzeit
 - reminderDate: lokale Date‑Repräsentation für den Wheel‑DatePicker

 Interaktion
 - Gegenseitiger Ausschluss der Modi (wenn einer aktiv, wird der andere deaktiviert).
 - Bei Änderungen: Werte speichern und ggf. Erinnerungen neu planen.

 Gestaltung & Barrierefreiheit
 - Überschrift, zwei Schalter in einer Material‑Karte, darunter ein Wheel‑DatePicker.
 - Farbverläufe im App‑Stil, klare Labels, Accessibility‑Labels.
*/
struct ReminderSettingsView: View {
    // MARK: - Umgebung & Persistenz
    @Environment(\.dismiss) private var dismiss

    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderInteractive") private var reminderInteractive: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 9
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    // MARK: - Lokaler Zustand
    /// Lokale Datumskomponente, die die ausgewählte Uhrzeit im Wheel‑Picker repräsentiert.
    @State private var reminderDate: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    // MARK: - Layout
    var body: some View {
        VStack(spacing: 24) {
            // Titel im App‑Stil
            HStack(spacing: 8) {
                Text("Erinnerungen")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Bereich: Schalter für Erinnerungen
            VStack(spacing: 16) {
                Toggle(isOn: $reminderEnabled) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text("Festgelegte Erinnerung")
                            .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .tint(.teal)
                .disabled(reminderInteractive)

                Toggle(isOn: $reminderInteractive) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text("Interaktive Erinnerung")
                            .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .tint(.teal)
                .disabled(reminderEnabled)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(colors: [Color.blue.opacity(0.45), Color.cyan.opacity(0.45)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )

            // Bereich: Uhrzeit wählen (Wheel‑DatePicker)
            VStack(alignment: .leading, spacing: 12) {
                Text("Uhrzeit")
                    .font(.headline)
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                DatePicker("Uhrzeit wählen", selection: $reminderDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .disabled(!reminderEnabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(colors: [Color.blue.opacity(0.45), Color.cyan.opacity(0.45)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .tint(.teal)
        // Toolbar mit Zurück- und Sichern-Aktionen
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                .accessibilityLabel("Zurück")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    saveAndSchedule()
                    dismiss()
                }) {
                    Text("Sichern")
                        .bold()
                        .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                .disabled(!reminderEnabled)
            }
        }
        // Beim Öffnen: Uhrzeit aus gespeicherten Werten laden
        .onAppear { syncDateFromStorage() }
        // Live‑Reaktionen auf Umschalten/Änderungen
        .onChange(of: reminderEnabled) { _, newValue in
            if newValue { reminderInteractive = false }
            saveAndSchedule()
        }
        .onChange(of: reminderInteractive) { _, newValue in
            if newValue { reminderEnabled = false }
            saveAndSchedule()
        }
        .onChange(of: reminderDate) { _, _ in
            if reminderEnabled { saveAndSchedule() }
        }
    }

    // MARK: - Logik: Synchronisieren & Planen
    /// Synchronisiert die lokale Date‑Auswahl aus den persistierten Stunden/Minuten.
    private func syncDateFromStorage() {
        let comps = DateComponents(hour: reminderHour, minute: reminderMinute)
        let date = Calendar.current.date(from: comps) ?? Date()
        reminderDate = date
    }

    /// Speichert die aktuellen Werte und plant/entfernt Benachrichtigungen über den NotificationManager.
    private func saveAndSchedule() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        reminderHour = comps.hour ?? 9
        reminderMinute = comps.minute ?? 0

        // Gegenseitigen Ausschluss beim Planen sicherstellen
        if reminderEnabled && reminderInteractive {
            reminderInteractive = false
        }

        if reminderEnabled {
            NotificationManager.requestAuthorization { granted in
                if granted {
                    NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute, interactive: reminderInteractive)
                }
            }
        } else {
            NotificationManager.cancelDailyReminders()
        }
    }
}

// MARK: - Vorschau
#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
}
