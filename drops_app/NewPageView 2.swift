import SwiftUI

struct NewPageView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Kalender")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                CalendarView()
            }
            .padding()
            .navigationTitle("Übersicht")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewPageView()
}
