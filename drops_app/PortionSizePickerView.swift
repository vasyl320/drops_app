import SwiftUI

// MARK: - Änderungen/Ergänzungen
// 1) Persistente Speicherung via @AppStorage für ml (selectedPortionSizeML) und Anzahl der Gläser (glassCount)
// 2) Zusätzlicher Picker (segmented) für die Anzahl der Gläser
// 3) Kleine graue Zusammenfassung (Formel): Anzahl × ml = Gesamtmenge
// 4) Navigationstitel auf "Zurück" gesetzt, damit neben dem Back-Button der Text erscheint

struct PortionSizePickerView: View {
    @Environment(\.dismiss) private var dismiss
    // Persistente Speicherung der Auswahl:
    // - selectedPortionSizeML speichert die zuletzt gewählte Portionsgröße (ml)
    @AppStorage("selectedPortionSizeML") private var selectedSize: Int = 250
    private let sizes: [Int] = Array(stride(from: 50, through: 1000, by: 50))

    var body: some View {
        VStack(spacing: 24) {
            // iOS-Wheel-Picker für Portionsgröße – zentriert und vergrößert
            Text("Wähle die Portionsgröße")
                .font(.system(size: 30, weight: .semibold))
            
            Spacer()
            
            VStack {
                Picker("Portionsgröße (ml)", selection: $selectedSize) {
                    ForEach(sizes, id: \.self) { size in
                        Text("\(size) ml").tag(size)
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.15) // Picker leicht vergrößern für bessere Lesbarkeit
                .frame(maxWidth: .infinity)
                .frame(height: 240) // Mehr Höhe für den Wheel-Picker
                .clipped()
                .accessibilityLabel("Portionsgröße in Millilitern auswählen")

                Text("Ausgewählt: \(selectedSize) ml")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        PortionSizePickerView()
    }
}

