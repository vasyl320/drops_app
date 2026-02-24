// ReminderSettingsView: Einstellungen für tägliche Erinnerungen
// - Aktivieren/Deaktivieren, interaktive Erinnerungen, Uhrzeitwahl
// - Optisch abgestimmt auf die App (blauer Stil, Wasserwellen)
import SwiftUI

struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Hauptschalter: Erinnerungen an/aus (persistiert)
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    // Zusätzlicher sanfter Hinweis (zweite Benachrichtigung)
    @AppStorage("reminderInteractive") private var reminderInteractive: Bool = false
    // Gewählte Stunde der Erinnerung
    @AppStorage("reminderHour") private var reminderHour: Int = 9
    // Gewählte Minute der Erinnerung
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    // Lokale Datumskomponente für den Wheel-DatePicker (aus Stunde/Minute)
    @State private var reminderDate: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    var body: some View {
        VStack(spacing: 24) {

            HStack(spacing: 8) {
                Image(systemName: "water.waves")
                    .imageScale(.large)
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))

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
                if !reminderEnabled {
                    .disabled(!reminderEnabled)
                    
                }
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
                    .overlay(
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.blue.opacity(0.06))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                    )
            )

            // Bereich: Uhrzeit wählen (Wheel-DatePicker)
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
                    .overlay(
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.blue.opacity(0.06))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                    )
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

        // Wenn Ein-/Ausschalten geändert wird: sofort speichern/planen
        .onChange(of: reminderEnabled) { _, newValue in
            // live update when toggling
            saveAndSchedule()
        }
        // Wenn Interaktivität geändert wird: bei aktivierten Erinnerungen neu planen
        .onChange(of: reminderInteractive) { _, newValue in
            if reminderEnabled { saveAndSchedule() }
        }
        // Wenn Uhrzeit geändert wird: bei aktivierten Erinnerungen neu planen
        .onChange(of: reminderDate) { _, newValue in
            if reminderEnabled { saveAndSchedule() }
        }
    }

    // Synchronisiert die lokale Date-Auswahl aus den persistierten Stunden/Minuten
    private func syncDateFromStorage() {
        let comps = DateComponents(hour: reminderHour, minute: reminderMinute)
        let date = Calendar.current.date(from: comps) ?? Date()
        reminderDate = date
    }

    // Speichert die aktuellen Werte und plant/entfernt Benachrichtigungen
    private func saveAndSchedule() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        reminderHour = comps.hour ?? 9
        reminderMinute = comps.minute ?? 0

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

// MARK: - WaveView for ocean style
struct WaveView: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat = 0
    var phaseSpeed: CGFloat = 1

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let width = rect.width
        let step = max(1, width / 120)

        path.move(to: CGPoint(x: 0, y: midY))
        var x: CGFloat = 0
        while x <= width {
            let relativeX = x / rect.width
            let y = midY + sin((relativeX * .pi * 2 * frequency) + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        // Close shape to bottom
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

extension View {
    func animatedWave(phaseSpeed: CGFloat) -> some View {
        self.modifier(WaveAnimationModifier(phaseSpeed: phaseSpeed))
    }
}

private struct WaveAnimationModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    var phaseSpeed: CGFloat

    func body(content: Content) -> some View {
        content
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    phase = .pi * 2 * phaseSpeed
                }
            }
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
}
