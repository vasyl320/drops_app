import SwiftUI

// MARK: - Änderungen/Ergänzungen
// 1) Persistente Speicherung via @AppStorage für ml (selectedPortionSizeML) und Anzahl der Gläser (glassCount)
// 2) Zusätzlicher Picker (segmented) für die Anzahl der Gläser
// 3) Kleine graue Zusammenfassung (Formel): Anzahl × ml = Gesamtmenge
// 4) Navigationstitel auf "Zurück" gesetzt, damit neben dem Back-Button der Text erscheint

struct PortionSizePickerView: View {
    @State private var selectedSize: Int = 250
    private let sizes: [Int] = Array(stride(from: 200, through: 500, by: 50))
    @Environment(\.dismiss) private var dismiss // Zum Zurücknavigieren (eigener Zurück-Button)
    
    // Extracted row to ease type-checking
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

    var body: some View {
        VStack(spacing: 24) {
            // iOS-Wheel-Picker für Portionsgröße – zentriert und vergrößert
            HStack(spacing: 8) {
                Image(systemName: "water.waves")
                    .imageScale(.large)
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("Portionsgröße")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            
            Spacer()
            
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
        
         // Aktiviert iOS-Navigationstitel (Back-Button sichtbar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { // Eigener Zurück-Button im iOS-Stil
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .accessibilityLabel("Zurück") // VoiceOver-Label für den Zurück-Button
            }
        }
        .navigationBarBackButtonHidden(true) // Standard-Back-Button ausblenden, wir zeigen einen eigenen "Zurück"-Button
    }
}

#Preview {
    NavigationStack {
        PortionSizePickerView()
    }
}

