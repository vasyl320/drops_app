import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            Text("Einstellungen")
                .font(.system(size: 34, weight: .bold))

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
       
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // Standard-iOS-Zurück-Button explizit sichtbar lassen
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

