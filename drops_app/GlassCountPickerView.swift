import SwiftUI

/*
 GlassCountPickerView – Auswahl der täglichen Glasanzahl
 ------------------------------------------------------
 Zweck
 - Ermöglicht die Auswahl der gewünschten Anzahl Gläser pro Tag via Wheel‑Picker.
 - Speichert die Auswahl persistent über @AppStorage("glassCount").

 Interaktion
 - Wheel‑Picker: Scrollen/Tippen ändert die Anzahl.
 - Toolbar: Eigener „Zurück“-Button blendet den Standard‑Back‑Button aus.

 Gestaltung & Barrierefreiheit
 - Große, klare Typografie mit Titel „Anzahl“.
 - Vergrößerter Wheel‑Picker (scaleEffect) für bessere Lesbarkeit.
 - Accessibility‑Label für den Picker, dynamische Pluralform in der Zusammenfassung.
*/
struct GlassCountPickerView: View {
    // MARK: - Umgebungen & Zustände
    @Environment(\.dismiss) private var dismiss

    /// Persistente Zielanzahl der Gläser. Änderungen werden systemweit übernommen.
    @AppStorage("glassCount") private var glassCount: Int = 1

    /// Erlaubte Auswahlwerte (1 bis 20) für den Wheel‑Picker.
    private let counts: [Int] = Array(1...20)

    // MARK: - Layout
    var body: some View {
        VStack(spacing: 24) {
            // Oberer Abstand, um den Titel optisch zu zentrieren
            Spacer()

            // Titelzeile mit Verlaufstext im App‑Stil
            HStack(spacing: 8) {
                Text("Anzahl")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }

            Spacer()

            // Inhalt: Wheel‑Picker + Zusammenfassung
            VStack {
                // Wheel‑Picker für die Anzahl der Gläser
                Picker("Anzahl der Gläser", selection: $glassCount) {
                    ForEach(counts, id: \.self) { count in
                        Text("\(count)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .tag(count)
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.45) // Picker vergrößern für bessere Lesbarkeit
                .frame(maxWidth: .infinity)
                .frame(height: 260) // Mehr Höhe für den Wheel‑Picker
                .clipped()
                .accessibilityLabel("Anzahl der Gläser auswählen")

                // Zusammenfassung mit korrekter Pluralform
                let glassText = glassCount == 1 ? "Glas" : "Gläser"

                Text("Ausgewählt: \(glassCount) \(glassText)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tint(.teal)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Unterer Abstand für ruhige Optik
            Spacer()
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        // MARK: - Toolbar mit eigenem Zurück‑Button
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Vorschau
#Preview {
    NavigationStack {
        GlassCountPickerView()
    }
}

