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
                        HStack(spacing: 8) {
                            Text("Los geht’s")
                            Image(systemName: "arrow.right.circle")
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 26, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
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
