import SwiftUI

struct NewPageView: View {
    @State private var zaehler: Int = 1

    var body: some View {
        VStack(spacing: 24) {
            Text("\(zaehler)/10")
                .font(.system(size: 60))
                .bold()

            Divider()

            Spacer()

            Image("image1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 2000)
                .onTapGesture { if zaehler < 10 { zaehler += 1 } }
                
        }
        .padding()
    }
}

#Preview {
    NewPageView()
}
