import SwiftUI

// Startansicht mit App-Branding und Navigation zum Zähler (CounterPageView)
struct ContentView: View {

    // Lokale Wrapper, um mehrdeutige Typnamen im Projekt zu vermeiden
    private struct SettingsScreen: View {
        var body: some View {
            // TODO: Hier die tatsächliche Einstellungen-Ansicht des Projekts einfügen
            Text("Settings")
                .navigationTitle("Einstellungen")
        }
    }

    private struct CalendarScreen: View {
        var body: some View {
            // TODO: Hier die tatsächliche Kalender-Ansicht des Projekts einfügen
            Text("Kalender")
                .navigationTitle("Kalender")
        }
    }

    var body: some View {
        // Navigation-Container für die Startseite
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    Spacer()
                    Spacer()

                    // App-Logo/Illustration
                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    Text("DROPS")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.black)
                        .padding(.top, 22)

                    // Haupt-Button: führt zum Zähler (CounterPageView)
                    NavigationLink {
                        CounterPageView()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Los geht’s")
                                .font(.system(size: 22, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 56)
                        // Optik: Kapsel mit einfarbigem blauen Hintergrund
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        // Optik: Wasserwellen-Overlay und glänzende Kontur mit einfarbiger Linie
                        .overlay(
                            ZStack {
                            
                                // Glänzender Rand
                                Capsule().strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                            }
                        )
                        // Weicher Schatten für Tiefe
                        .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
                    }
                    .padding(.top, 24)

                    Spacer()
                    // Zentralen NavigationLink-Button entfernt
                    Spacer()
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}

