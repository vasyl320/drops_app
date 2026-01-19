import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
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

                NavigationLink(destination: NewPageView()) {
                    HStack(spacing: 8) {
                        Text("Los Gehts")
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 33, weight: .semibold))
                    .padding(.horizontal, 33)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(Color(.systemGray6))
                    )
                }

                Spacer()
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 25))
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
