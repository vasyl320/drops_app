import SwiftUI

struct ContentView: View {
    // Local wrappers to avoid ambiguous type names elsewhere in the project
    private struct SettingsScreen: View {
        var body: some View {
            // TODO: Replace with the intended Settings view in your project
            Text("Settings")
                .navigationTitle("Einstellungen")
        }
    }

    private struct CalendarScreen: View {
        var body: some View {
            // TODO: Replace with the intended Calendar view in your project
            Text("Kalender")
                .navigationTitle("Kalender")
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    Spacer()
                    Spacer()

                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    Text("DROPS")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.black)
                        .padding(.top, 22)

                    NavigationLink {
                        CounterPageView()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Los geht’s")
                                .font(.system(size: 22, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 56)
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
                                    .font(.system(size: 64))
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
                        .shadow(color: Color.cyan.opacity(0.25), radius: 10, x: 0, y: 6)
                    }
                    .padding(.top, 24)

                    Spacer()
                    // Removed central NavigationLink button
                    Spacer()
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
