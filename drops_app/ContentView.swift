import SwiftUI

/*
 ContentView – Startbildschirm der App
 -------------------------------------
 Zweck:
 - Zeigt Logo und App-Namen.
 - Bietet den primären Call‑to‑Action „Los geht’s“, der zur Zähleransicht (CounterPageView) führt.

 Navigation:
 - Verwendet NavigationStack als Container, damit NavigationLinks eine History erhalten.
 - Der CTA öffnet CounterPageView.

 Gestaltung:
 - Vertikale Anordnung mit mehreren Spacern, um das Logo/Branding optisch zu zentrieren.
 - Meer‑Stil Button: LinearGradient (Blau → Cyan → Teal) mit glänzendem Kontur‑Stroke.
 - Sanfter Schatten für räumliche Tiefe.

 Hinweise:
 - Die beiden eingebetteten Platzhalteransichten (SettingsScreen/CalendarScreen) sind nur Beispiele
   zur Vermeidung von Namenskollisionen. Sie können später durch echte Screens ersetzt oder entfernt werden.
*/
struct ContentView: View {

    // MARK: - Platzhalteransichten (können bei Bedarf ersetzt/entfernt werden)
    /// Einfache Platzhalter-Ansicht für Einstellungen. Dient nur der Typtrennung in dieser Datei.
    private struct SettingsScreen: View {
        var body: some View {
            Text("Settings")
                .navigationTitle("Einstellungen")
        }
    }

    /// Einfache Platzhalter-Ansicht für einen Kalender. Dient nur der Typtrennung in dieser Datei.
    private struct CalendarScreen: View {
        var body: some View {
            Text("Kalender")
                .navigationTitle("Kalender")
        }
    }

    // MARK: - Inhalt
    var body: some View {
//        NavigationStack stellt den Navigationskontext für alle NavigationLinks bereit.
        NavigationStack {
//                                     ZStack mit bottom‑Alignment, damit spätere, am unteren Rand schwebende Elemente
            // (z. B. Toolbars oder Bottom‑Buttons) leicht ergänzt werden können.
            ZStack(alignment: .bottom) {
                // Hauptsäule für Logo, Titel und Call‑to‑Action
                VStack {
                    // Mehrere Spacer sorgen für eine optische Zentrierung des Brandings im oberen Bereich.
                    Spacer()
                    Spacer()

                    // App‑Logo (aus den Assets). Größe wird über den Frame begrenzt.
                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    // App‑Titel in markanter, sehr fetter Typografie.
                    Text("DROPS")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.black)
                        .padding(.top, 22)

                    // Primärer Call‑to‑Action: Öffnet die Zähleransicht (CounterPageView).
                    NavigationLink {
                        CounterPageView()
                    } label: {
                        // Beschriftung des Buttons: Text + Pfeil‑Icon
                        HStack(spacing: 10) {
                            Text("Los geht’s")
                                .font(.system(size: 22, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                        }
                        // Weiße Schrift für maximale Lesbarkeit auf dem farbigen Hintergrund.
                        .foregroundColor(.white)
                        // Innenabstand: sorgt für großen, gut klickbaren Bereich.
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        // Breite an verfügbare Breite anpassen; Mindesthöhe für Touch‑Ziele.
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 56)

                        // Hintergrund: Meer‑Stil mit weichem Farbverlauf (Blau → Cyan → Teal)
                        // in einer Kapsel‑Form.
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                        )

                        // Glänzende Kontur: subtiler Verlauf von Weiß‑Deckkraft für „polierten“ Rand.
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

                        // Schatten: leichte Tiefe und Abhebung vom Hintergrund.
                        .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
                    }
                    .padding(.top, 24)

                    // Weitere Spacer, um den unteren Bereich zu strecken und das Layout ruhig zu halten.
                    Spacer()
                    Spacer()
                    Spacer()
                }
                // Außenabstand für die gesamte Spalte, damit Inhalte nicht am Rand kleben.
                .padding()
            }
        }
    }
}

// MARK: - Vorschau
#Preview {
    ContentView()
}

