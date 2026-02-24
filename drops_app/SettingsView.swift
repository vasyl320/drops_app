// SettingsView: Einstellungen für Portionsgröße, Glasanzahl und Erinnerungen
// - Zeigt Formel (Gesamt = Anzahl × ml)
// - Drei große Navigations-Buttons im einheitlichen Kapsel-/Gradient-Stil
import SwiftUI

struct SettingsView: View {
    // Ausgewählte Portionsgröße in Millilitern (persistiert)
    @AppStorage("portionSizeMl") private var selectedSize: Int = 250
    // Gewählte Anzahl der Gläser (persistiert)
    @AppStorage("glassCount") private var glassCount: Int = 1

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Formel-Box: zeigt live die Gesamtsumme in ml
            // Formel-Box: Gesamtmenge = Anzahl × ml (enhanced visibility)
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
                    Image(systemName: "water.waves")
                        .font(.system(size: 70))
                        .foregroundColor(.white.opacity(0.10))
                        .rotationEffect(.degrees(8))
                        .offset(x: 8, y: -8)
                        .allowsHitTesting(false)
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
            // First big button
            NavigationLink(destination: PortionSizePickerView()) {
                HStack(spacing: 10) {
                    Text("Portionsgröße wählen")
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
                        // Subtle water waves overlay
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                        // Glossy stroke
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .padding(.top, 12)
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            // Button: Anzahl Gläser wählen
            // Second big button
            NavigationLink(destination: GlassCountPickerView()) {
                HStack(spacing: 10) {
                    Text("Anzahl Gläser wählen")
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
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .padding(.bottom, 8)
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            // Button: Erinnerungen konfigurieren
            // Third big button
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
                        // Subtle water waves overlay
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                        // Glossy stroke
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

