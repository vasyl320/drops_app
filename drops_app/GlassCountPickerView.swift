import SwiftUI

struct GlassCountPickerView: View {
    @State private var glassCount: Int = 1
    private let counts: [Int] = Array(1...20)

    var body: some View {
        VStack(spacing: 24) {
            // iOS-Wheel-Picker für Anzahl der Gläser – zentriert und vergrößert
            Spacer()
            Text("Anzahl")
                .font(.system(size: 50, weight: .semibold))
            
            Spacer()
            
            VStack {
                Picker("Anzahl der Gläser", selection: $glassCount) {
                    ForEach(counts, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.15) // Picker leicht vergrößern für bessere Lesbarkeit
                .frame(maxWidth: .infinity)
                .frame(height: 240) // Mehr Höhe für den Wheel-Picker
                .clipped()
                .accessibilityLabel("Anzahl der Gläser auswählen")

                Text("Ausgewählt: \(glassCount) Glas\(glassCount == 1 ? "" : "er")")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            Spacer()
        }
        .padding()
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // iOS-Back-Button explizit einblenden
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        GlassCountPickerView()
    }
}
