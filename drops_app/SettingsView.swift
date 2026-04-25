import SwiftUI

/*
 SettingsView – zentrale Einstellungen der App
 --------------------------------------------
 Zweck
 - Drei Einstellungsbereiche über große, einheitliche Navigationsbuttons:
   1) Portionsgröße (ml)
   2) Anzahl Gläser (Ziel)
   3) Erinnerungen (Benachrichtigungen)
 - Eine Formel-Box zeigt live die Gesamtsumme (Anzahl × ml).

 Daten
 - @AppStorage("portionSizeMl") und @AppStorage("glassCount") spiegeln die aktuellen Werte.

 Gestaltung
 - Einheitlicher „Meer‑Stil“: Kapsel mit Gradient (Blau → Cyan → Teal), glänzender Rand, weicher Schatten.
 - Große Typografie, breite Touch‑Ziele.
*/
struct SettingsView: View {
    @AppStorage("portionSizeMl") private var selectedSize: Int = 250
    @AppStorage("glassCount") private var glassCount: Int = 1

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Formel-Box: zeigt live die Gesamtsumme in ml (Anzahl × ml)
            HStack(spacing: 10) {
                Image(systemName: "sum")
                    .font(.system(size: 22, weight: .bold))
                Text("Gesamt: \(glassCount) × \(selectedSize) ml = \(glassCount * selectedSize) ml")
                    .font(.system(size: 20, weight: .semibold))
                    .monospacedDigit()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                ZStack {
                    Capsule().strokeBorder(
                        LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing),
                        lineWidth: 1.2
                    )
                }
            )
            .shadow(color: Color.cyan.opacity(0.25), radius: 8, x: 0, y: 4)
            .accessibilityLabel("Gesamte Wassermenge: \(glassCount * selectedSize) Milliliter")

            Spacer()

            // Button: Portionsgröße wählen
            NavigationLink(destination: PortionSizePickerView()) {
                HStack(spacing: 10) {
                    Text("Portionsgröße")
                        .font(.system(size: 28, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 84)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    ZStack {
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            // Button: Anzahl Gläser wählen
            NavigationLink(destination: GlassCountPickerView()) {
                HStack(spacing: 10) {
                    Text("Anzahl Gläser")
                        .font(.system(size: 28, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 84)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    ZStack {
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            // Button: Erinnerungen konfigurieren
            NavigationLink(destination: ReminderSettingsView()) {
                HStack(spacing: 10) {
                    Text("Erinnerungen")
                        .font(.system(size: 28, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 84)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    ZStack {
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

