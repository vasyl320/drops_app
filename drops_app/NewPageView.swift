import SwiftUI

struct CounterPageView: View {
    @State private var zaehler: Int = 1
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 24) {
                Text("\(zaehler)/10")
                    .font(.system(size: 60))
                    .fontWeight(.black)
                    .bold()
                    .padding(.top, 80)

                Divider()

                

                Image("image1")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 600)
                    .frame(maxWidth: 2000)
                    .padding(.bottom, 80)
                    .onTapGesture { if zaehler < 10 { zaehler += 1 } }
            }

            HStack(spacing: 20) {
                // Bottom-left: Calendar
                NavigationLink {
                    CalendarView()
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                        .accessibilityLabel("Kalender")
                }

                // Bottom-right: Settings
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                        .accessibilityLabel("Einstellungen")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 67)
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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CounterPageView()
}
