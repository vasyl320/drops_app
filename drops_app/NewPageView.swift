import SwiftUI

struct NewPageView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("1/10 ")
                .font(.system(size: 60))
                .bold()

            Divider()

            Spacer()

            NavigationLink(destination: NewPageViewTwo()) {
             Image("image1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 2000)
                .accessibilityLabel("Bild drücken")
            }

      Spacer()
        }
        .padding()
    }
}

#Preview {
    NewPageView()
}
