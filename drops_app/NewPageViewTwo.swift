import SwiftUI

struct NewPageViewTwo: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("2/10")
                .font(.system(size: 48, weight: .bold))
            Divider()
            Text("This is the second page.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
        .navigationTitle("Page 2")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NewPageViewTwo()
    }
}
