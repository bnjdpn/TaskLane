import SwiftUI

/// Clock widget for the taskbar (legacy - use SystemTrayView instead)
struct ClockView: View {
    let format: ClockFormat

    @State private var currentTime = Date()

    // Timer to update the clock
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(currentTime, format: format.dateStyle)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        ClockView(format: .short)
        ClockView(format: .medium)
        ClockView(format: .full)
    }
    .padding()
    .background(Color(nsColor: .windowBackgroundColor))
}
