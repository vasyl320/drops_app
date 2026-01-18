import SwiftUI

struct WhitePageView: View {
    let title: String

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WhitePageView(title: "Beispiel")
    }
}
