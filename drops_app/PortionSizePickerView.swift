import SwiftUI

struct PortionSizePickerView: View {
    @State private var selectedSize: Int = 250
    private let sizes: [Int] = Array(stride(from: 50, through: 1000, by: 50))

    var body: some View {
        VStack(spacing: 24) {
            // iOS-Wheel-Picker für Portionsgröße – zentriert und vergrößert
            Text("Wähle die Portionsgröße")
                .font(.system(size: 22, weight: .semibold))
            
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
         // Aktiviert iOS-Navigationstitel (Back-Button sichtbar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // iOS-Back-Button explizit einblenden
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        PortionSizePickerView()
    }
}
