import SwiftUI

struct PortionSizePickerView: View {
    @State private var selectedSize: Int = 250
    private let sizes: [Int] = Array(stride(from: 200, through: 500, by: 50))
    @Environment(\.dismiss) private var dismiss // Zum Zurücknavigieren (eigener Zurück-Button)

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
                .scaleEffect(1.75) // Picker leicht vergrößern für bessere Lesbarkeit
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
        
         // Aktiviert iOS-Navigationstitel (Back-Button sichtbar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { // Eigener Zurück-Button im iOS-Stil
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Zurück") // Label hinzufügen
                    }
                }
                .accessibilityLabel("Zurück") // VoiceOver-Label für den Zurück-Button
            }
        }
        .navigationBarBackButtonHidden(true) // Standard-Back-Button ausblenden, wir zeigen einen eigenen "Zurück"-Button
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        PortionSizePickerView()
    }
}
