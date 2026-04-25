import SwiftUI

/*
 PortionSizePickerView – Auswahl der Portionsgröße (ml)
 -----------------------------------------------------
 Zweck
 - Nutzer wählt die Menge pro Glas (in Millilitern) über einen Wheel‑Picker.
 - Die Ausw=ahl wird persistent via @AppStorage("portionSizeMl") gespeichert.

 Interaktion
 - Wheel‑Picker: Scrollen/Tippen ändert die ml‑Menge.
 - Eigener Zurück‑Button in der Toolbar blendet den Standard‑Back‑Button aus.

 Gestaltung & Barrierefreiheit
 - Titel „Portionsgröße“ in großer, klarer Typografie.
 - Vergrößerter Wheel‑Picker (scaleEffect) für bessere Lesbarkeit.
 - Live‑Anzeige der gewählten ml‑Zahl, monospacedDigit in der Formel.
*/
struct PortionSizePickerView: View {
    // MARK: - Zustände & Daten
    /// Persistente Auswahl der Portionsgröße (in Millilitern).
    @AppStorage("portionSizeMl") private var selectedSize: Int = 250

    /// Verfügbare ml‑Werte von 200 bis 500 in 50er‑Schritten.
    private let sizes: [Int] = Array(stride(from: 200, through: 500, by: 50))

    /// Umgebung zum Schließen der Ansicht (Zurück‑Navigation).
    @Environment(\.dismiss) private var dismiss

    // MARK: - Hilfsdarstellung für Pickerzeile
    @ViewBuilder
    private func row(for size: Int) -> some View {
        let isSelected: Bool = (size == selectedSize)
        let font: Font = .system(size: isSelected ? 32 : 22, weight: isSelected ? .bold : .regular, design: .rounded)
        let color: Color = isSelected ? .teal : Color.teal.opacity(0.6)

        Text("\(size) ml")
            .font(font)
            .foregroundColor(color)
            .tag(size)
    }

    // MARK: - Layout
    var body: some View {
        VStack(spacing: 24) {
            // Titelzeile im App‑Stil
            HStack(spacing: 8) {
                Text("Portionsgröße")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }

            Spacer()

            // Wheel‑Picker + Live‑Anzeige
            VStack(spacing: 12) {
                Picker("Portionsgröße (ml)", selection: $selectedSize) {
                    ForEach(sizes, id: \.self) { size in
                        row(for: size)
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.45)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipped()
                .accessibilityLabel("Portionsgröße in Millilitern auswählen")

                Text("Ausgewählt: \(selectedSize) ml")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tint(.teal)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding()
        .tint(.teal)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Eigener Zurück‑Button im iOS‑Stil
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .accessibilityLabel("Zurück")
            }
                }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        PortionSizePickerView()
    }
}
                        
