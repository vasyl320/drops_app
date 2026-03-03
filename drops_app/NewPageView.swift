// CounterPageView: Zähler- und Füll-Logik der Gläser-Ansicht
// - Passt sich dynamisch an die in den Einstellungen gewählte Anzahl Gläser an
// - Skaliert die Füllstufen (0–10) proportional zum Ziel
// - Markiert den Tag im Kalender, wenn das Ziel erreicht ist

import SwiftUI
import UIKit

// Haupt-View für den Tageszähler
struct CounterPageView: View {
    // Aktueller Tagesstand (Zähler) – wird täglich zurückgesetzt
    @AppStorage("todayCount") private var zaehler: Int = 0
    // Datum des letzten Zähler-Updates (für Tageswechsel)
    @AppStorage("todayCountDate") private var lastCountDate: String = ""
    // Animations-Flags für die Flammen-/Glüh-Effekte
    @State private var flamePulse: Bool = false
    @State private var glowPulse: Bool = false
    // Speichert, ob der heutige Tag als "erreicht" markiert ist (Kalender-Flamme)
    @AppStorage("todayFlameDate") private var todayFlameDate: String = ""
    // Zielanzahl Gläser (aus Einstellungen)
    @AppStorage("glassCount") private var targetGlasses: Int = 10
    // Bildstufen für die Gläser-Füllung (0–10)
    private let glassImages: [String] = [
        "glass_0", "glass_1", "glass_2", "glass_3", "glass_4",
        "glass_5", "glass_6", "glass_7", "glass_8", "glass_9", "glass_10"
    ]
    
    // Schutz gegen ungültige Werte (mindestens 1 Glas)
    private var maxGlasses: Int { max(targetGlasses, 1) }
    // Skaliert den Zähler (0..Ziel) auf Bildindex (0..10)
    private var fillIndex: Int {
        let ratio = Double(zaehler) / Double(maxGlasses)
        return min(10, max(0, Int(round(ratio * 10.0))))
    }
    
    // Liefert das heutige Datum als Schlüssel (yyyy-MM-dd)
    private func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 24) {
                ZStack {
                    // Anzeige "x/y" mit dynamischem Ziel
                    HStack(spacing: 10) {
                        Text("\(zaehler)/\(maxGlasses)")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .monospacedDigit()
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 34, weight: .bold))
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(
                        LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .shadow(color: Color.cyan.opacity(0.25), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(.systemBackground).opacity(0.0))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 1.25
                            )
                            .opacity(0.9)
                    )
                    // Subtle water waves overlay for flair
                    Image(systemName: "water.waves")
                        .font(.system(size: 90, weight: .regular))
                        .foregroundColor(.blue.opacity(0.06))
                        .rotationEffect(.degrees(8))
                        .offset(x: 14, y: -18)
                        .allowsHitTesting(false)
                }
                .padding(.top, 70)
                .animation(.easeInOut(duration: 0.2), value: zaehler)

                Divider()

                ZStack {
                    // Voll – Ziel erreicht: zeige runden Navigations-Button zum Kalender
                    if zaehler == maxGlasses {
                        // Blue fire badge in sea style when full
                        NavigationLink {
                            CalendarView()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "water.waves")
                                            .font(.system(size: 80, weight: .regular))
                                            .foregroundColor(.white.opacity(0.12))
                                            .rotationEffect(.degrees(8))
                                            .offset(x: 6, y: -6)
                                            .clipShape(Circle())
                                    )
                                    .overlay(
                                        Circle().strokeBorder(
                                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing),
                                            lineWidth: 2
                                        )
                                    )
                                    .shadow(color: Color.cyan.opacity(0.35), radius: 16, x: 0, y: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(colors: [Color.cyan.opacity(glowPulse ? 0.45 : 0.12), Color.teal.opacity(0.0)],
                                                               startPoint: .center,
                                                               endPoint: .bottomTrailing)
                                            )
                                            .blur(radius: glowPulse ? 10 : 2)
                                            .scaleEffect(glowPulse ? 1.05 : 1.0)
                                    )
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 48, weight: .black))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color.white)
                                    .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        LinearGradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.0)],
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                            .mask(
                                                Image(systemName: "flame.fill")
                                                    .font(.system(size: 48, weight: .black))
                                            )
                                    )
                                    .offset(y: flamePulse ? -1.5 : 1.5)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: flamePulse)
                            }
                            .contentShape(Circle())
                            .accessibilityLabel("Zum Kalender")
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .offset(y: -300)
                        .zIndex(2)
                        .transition(.scale.combined(with: .opacity))
                        .scaleEffect(flamePulse ? 1.06 : 1.0)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: flamePulse)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glowPulse)
                        .onAppear {
                            flamePulse = true
                            glowPulse = true
                        }
                        .onDisappear {
                            flamePulse = false
                            glowPulse = false
                        }
                        .symbolEffect(.pulse.byLayer, options: .repeating.speed(1.2))
                    }
                    
                    if zaehler > 0 {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.22)) {
                                zaehler -= 1
                            }
                            lastCountDate = todayKey()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
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
                                        .font(.system(size: 64, weight: .regular))
                                        .foregroundColor(.white.opacity(0.12))
                                        .rotationEffect(.degrees(8))
                                        .offset(x: 4, y: -4)
                                        .clipShape(Circle())
                                )
                                .overlay(
                                    Circle().strokeBorder(
                                        LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing),
                                        lineWidth: 2
                                    )
                                )
                                .shadow(color: Color.cyan.opacity(0.35), radius: 16, x: 0, y: 10)
                                .contentShape(Circle())
                                .accessibilityLabel("Zurück")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .offset(y: -200)
                        .zIndex(1)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                    // Füllbild basierend auf skaliertem Index
                    Image(glassImages[fillIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(minHeight: 600)
                        .frame(maxWidth: 2000)
                        .id(glassImages[fillIndex])
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        .contentShape(Rectangle())
                        .zIndex(0)
                        .onTapGesture {
                            // Inkrementiere Zähler, solange Ziel nicht erreicht
                            if zaehler < maxGlasses {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    zaehler += 1
                                    lastCountDate = todayKey()
                                }
                                // If we just reached 10, mark today for the calendar flame
                                if zaehler == maxGlasses {
                                    let formatter = DateFormatter()
                                    formatter.calendar = Calendar.current
                                    formatter.locale = Locale.current
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    todayFlameDate = formatter.string(from: Date())
                                }
                            }
                        }
                }
                .padding(.bottom, 80)
                .animation(.easeInOut(duration: 0.22), value: zaehler)
            }

            HStack(spacing: 20) {
                // Bottom-left: Calendar
                NavigationLink {
                    CalendarView()
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
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
                                .font(.system(size: 64, weight: .regular))
                                .foregroundColor(.white.opacity(0.12))
                                .rotationEffect(.degrees(8))
                                .offset(x: 4, y: -4)
                                .clipShape(Circle())
                        )
                        .overlay(
                            Circle().strokeBorder(
                                LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.35), radius: 16, x: 0, y: 10)
                        .contentShape(Circle())
                        .accessibilityLabel("Kalender")
                }

                // Bottom-right: Settings
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
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
                                .font(.system(size: 64, weight: .regular))
                                .foregroundColor(.white.opacity(0.12))
                                .rotationEffect(.degrees(8))
                                .offset(x: 4, y: -4)
                                .clipShape(Circle())
                        )
                        .overlay(
                            Circle().strokeBorder(
                                LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.35), radius: 16, x: 0, y: 10)
                        .contentShape(Circle())
                        .accessibilityLabel("Einstellungen")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 67)
        }
        // Tageswechsel: Zähler bei neuem Tag zurücksetzen
        .onAppear {
            let today = todayKey()
            if lastCountDate != today {
                zaehler = 0
                lastCountDate = today
            }
            // Clamp current count to current goal when appearing
            let currentGoal = max(1, targetGlasses)
            if zaehler > currentGoal {
                zaehler = currentGoal
            }
        }
        // Ziel geändert: aktuellen Stand beibehalten, ggf. auf neues Ziel begrenzen
        .onChange(of: targetGlasses) { _, newValue in
            let newGoal = max(1, newValue)
            if zaehler > newGoal {
                zaehler = newGoal
            }
            lastCountDate = todayKey()
        }
        .padding()
        // Zahnrad in der Toolbar entfernt as per instructions
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CounterPageView()
}

