import SwiftUI

struct GlassCountPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("glassCount") private var glassCount: Int = 1
    private let counts: [Int] = Array(1...20)
    
    @State private var isDragging: Bool = false
    private var headerGradient: LinearGradient {
        LinearGradient(colors: [Color.accentColor.opacity(0.9), Color.accentColor.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            // Subtle background gradient
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 8)

                // Title with gradient style
                Text("Anzahl")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(headerGradient)
                    .accessibilityAddTraits(.isHeader)

                // Card container for wheel picker
                ZStack {
                    // Glass / material card
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)

                    VStack(spacing: 16) {
                        Picker("Anzahl der Gläser", selection: $glassCount) {
                            ForEach(counts, id: \.self) { count in
                                Text("\(count)")
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .tag(count)
                            }
                        }
                        .pickerStyle(.wheel)
                        .scaleEffect(1.1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 230)
                        .clipped()
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture().onChanged { _ in
                                if !isDragging { isDragging = true; UIImpactFeedbackGenerator(style: .light).impactOccurred() }
                            }.onEnded { _ in
                                isDragging = false
                            }
                        )
                        .accessibilityLabel("Anzahl der Gläser auswählen")

                        // Selection readout
                        Text("Ausgewählt: \(glassCount) Glas\(glassCount == 1 ? "" : "er")")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                    }
                    .padding(20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { UISelectionFeedbackGenerator().selectionChanged(); dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GlassCountPickerView()
    }
}
