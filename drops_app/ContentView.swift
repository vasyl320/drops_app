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

                    Spacer()
                    // Removed central NavigationLink button
                    Spacer()
                    Spacer()
                }
                .padding()

                HStack {
                    // Bottom-left: Calendar
                    NavigationLink {
                        CalendarScreen()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                            Text("Kalender")
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                    }

                    Spacer()

                    // Bottom-right: Settings
                    NavigationLink {
                        SettingsScreen()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Einstellungen")
                            Image(systemName: "gearshape")
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ContentView()
}
