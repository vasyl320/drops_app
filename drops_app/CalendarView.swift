import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Calendar")
                .font(.largeTitle.bold())

            Text("This is a placeholder for your calendar screen.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
}
