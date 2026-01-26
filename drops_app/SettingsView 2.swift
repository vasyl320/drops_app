import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Einstellungen")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
