import SwiftUI

struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Persisted settings
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderInteractive") private var reminderInteractive: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 9
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    // Local date binding composed from hour/minute for the wheel date picker
    @State private var reminderDate: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)

            Text("Erinnerungen")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Toggles
            VStack(spacing: 16) {
                Toggle(isOn: $reminderEnabled) {
                    Label("Erinnerungen aktivieren", systemImage: "bell")
                }
                .tint(.blue)

                Toggle(isOn: $reminderInteractive) {
                    Label("Interaktive Erinnerungen", systemImage: "hand.tap")
                }
                .tint(.blue)
                .disabled(!reminderEnabled)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemGray6)))

            // Time picker in iOS wheel style
            VStack(alignment: .leading, spacing: 12) {
                Text("Uhrzeit")
                    .font(.headline)
                DatePicker("Uhrzeit wählen", selection: $reminderDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .disabled(!reminderEnabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemGray6)))

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Zurück")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sichern") {
                    saveAndSchedule()
                    dismiss()
                }
                .bold()
                .disabled(!reminderEnabled)
            }
        }
        .onAppear { syncDateFromStorage() }
        .onChange(of: reminderEnabled) { _, newValue in
            // live update when toggling
            saveAndSchedule()
        }
        .onChange(of: reminderInteractive) { _, newValue in
            if reminderEnabled { saveAndSchedule() }
        }
        .onChange(of: reminderDate) { _, newValue in
            if reminderEnabled { saveAndSchedule() }
        }
    }

    private func syncDateFromStorage() {
        let comps = DateComponents(hour: reminderHour, minute: reminderMinute)
        let date = Calendar.current.date(from: comps) ?? Date()
        reminderDate = date
    }

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

#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
}
