import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedPortionSizeML") private var selectedSize: Int = 250
    @AppStorage("glassCount") private var glassCount: Int = 1

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Formel-Box: Gesamtmenge = Anzahl × ml (standard style)
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
            NavigationLink(destination: PortionSizePickerView()) {
                HStack(spacing: 10) {
                    Text("Portionsgröße wählen")
                        .font(.system(size: 28, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 84)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    ZStack {
                        // Subtle water waves overlay
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                        // Glossy stroke
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .padding(.top, 12)
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            // Second big button
            NavigationLink(destination: GlassCountPickerView()) {
                HStack(spacing: 10) {
                    Text("Anzahl Gläser wählen")
                        .font(.system(size: 28, weight: .semibold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 84)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(colors: [Color.blue, Color.cyan, Color.teal],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                )
                .overlay(
                    ZStack {
                        Image(systemName: "water.waves")
                            .font(.system(size: 76))
                            .foregroundColor(.white.opacity(0.10))
                            .rotationEffect(.degrees(8))
                            .offset(x: 8, y: -8)
                            .allowsHitTesting(false)
                        Capsule().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.08)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                    }
                )
                .padding(.bottom, 8)
                .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

