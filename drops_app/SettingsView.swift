import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedPortionSizeML") private var selectedSize: Int = 250
    @AppStorage("glassCount") private var glassCount: Int = 1

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Formel-Box: Gesamtmenge = Anzahl × ml
            HStack(spacing: 8) {
                Image(systemName: "sum")
                Text("Gesamt: \(glassCount) × \(selectedSize) ml = \(glassCount * selectedSize) ml")
                    .font(.subheadline)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .foregroundColor(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel("Gesamte Wassermenge: \(glassCount * selectedSize) Milliliter")

            Spacer()

            // First big button
            NavigationLink(destination: PortionSizePickerView()) { // Navigiert zum iOS-Wheel-Picker für die Portionsgröße
                HStack {
                    Text("Portionsgröße wählen")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                )
            }

            // Second big button
            NavigationLink(destination: GlassCountPickerView()) { // Navigiert zum iOS-Wheel-Picker für die Anzahl der Gläser
                HStack {
                    Text("Anzahl Gläser wählen")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                )
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Einstellungen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

