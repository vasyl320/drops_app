import SwiftUI

struct GlassCountPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("glassCount") private var glassCount: Int = 1
    private let counts: [Int] = Array(1...20)

    var body: some View {
        VStack(spacing: 24) {
            // iOS-Wheel-Picker für Anzahl der Gläser – zentriert und vergrößert
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "water.waves")
                    .imageScale(.large)
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("Anzahl")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            
            Spacer()
            
            VStack {
                Picker("Anzahl der Gläser", selection: $glassCount) {
                    ForEach(counts, id: \.self) { count in
                        Text("\(count)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .tag(count)
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(1.45) // Picker leicht vergrößern für bessere Lesbarkeit
                .frame(maxWidth: .infinity)
                .frame(height: 260) // Mehr Höhe für den Wheel-Picker
                .clipped()
                .accessibilityLabel("Anzahl der Gläser auswählen")

                Text("Ausgewählt: \(glassCount) Glas\(glassCount == 1 ? "" : "er")")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tint(.teal)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
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
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        GlassCountPickerView()
    }
}
