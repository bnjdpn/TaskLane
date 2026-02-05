import SwiftUI

/// Main taskbar SwiftUI view - Windows 11 style
struct TaskbarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        let settings = appState.settings

        ZStack {
            // Background - fills entire panel
            backgroundView(for: settings)

            // Content
            if settings.position.isHorizontal {
                HStack(spacing: 0) {
                    if settings.centerIcons {
                        Spacer(minLength: 0)
                    }

                    // App buttons section
                    appButtonsSection
                        .padding(.horizontal, 4)

                    Spacer(minLength: 0)

                    // System tray (clock)
                    systemTray
                        .padding(.trailing, 8)
                }
                .padding(.horizontal, 8)
            } else {
                VStack(spacing: 0) {
                    if settings.centerIcons {
                        Spacer(minLength: 0)
                    }

                    appButtonsSection
                        .padding(.vertical, 4)

                    Spacer(minLength: 0)

                    systemTray
                        .padding(.bottom, 8)
                }
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Background

    @ViewBuilder
    private func backgroundView(for settings: TaskLaneSettings) -> some View {
        if settings.useBlurEffect {
            VisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow
            )
        } else {
            Rectangle()
                .fill(Color(nsColor: .windowBackgroundColor))
        }
    }

    // MARK: - App Buttons Section

    @ViewBuilder
    private var appButtonsSection: some View {
        let pinnedItems = appState.taskbarItems.filter { $0.isPinned }
        let runningOnlyItems = appState.taskbarItems.filter { !$0.isPinned && $0.isRunning }
        let isHorizontal = appState.settings.position.isHorizontal

        if isHorizontal {
            HStack(spacing: 4) {
                // Pinned apps
                ForEach(pinnedItems) { item in
                    AppButtonView(item: item)
                }

                // Separator between pinned and running-only apps
                if !pinnedItems.isEmpty && !runningOnlyItems.isEmpty {
                    TaskbarSeparator(isHorizontal: true)
                        .padding(.horizontal, 6)
                }

                // Running apps (not pinned)
                ForEach(runningOnlyItems) { item in
                    AppButtonView(item: item)
                }
            }
        } else {
            VStack(spacing: 4) {
                // Pinned apps
                ForEach(pinnedItems) { item in
                    AppButtonView(item: item)
                }

                // Separator
                if !pinnedItems.isEmpty && !runningOnlyItems.isEmpty {
                    TaskbarSeparator(isHorizontal: false)
                        .padding(.vertical, 6)
                }

                // Running apps (not pinned)
                ForEach(runningOnlyItems) { item in
                    AppButtonView(item: item)
                }
            }
        }
    }

    // MARK: - System Tray

    @ViewBuilder
    private var systemTray: some View {
        let isHorizontal = appState.settings.position.isHorizontal

        if isHorizontal {
            HStack(spacing: 4) {
                if appState.settings.showClock {
                    SystemTrayView(format: appState.settings.clockFormat, showDate: appState.settings.showDate)
                }
                ShowDesktopButton(isHorizontal: true)
            }
        } else {
            VStack(spacing: 4) {
                if appState.settings.showClock {
                    SystemTrayView(format: appState.settings.clockFormat, showDate: appState.settings.showDate)
                }
                ShowDesktopButton(isHorizontal: false)
            }
        }
    }
}

// MARK: - Taskbar Separator (Windows 11 style)

struct TaskbarSeparator: View {
    let isHorizontal: Bool

    var body: some View {
        if isHorizontal {
            RoundedRectangle(cornerRadius: 0.5)
                .fill(Color.primary.opacity(0.2))
                .frame(width: 1, height: 24)
        } else {
            RoundedRectangle(cornerRadius: 0.5)
                .fill(Color.primary.opacity(0.2))
                .frame(width: 24, height: 1)
        }
    }
}

// MARK: - System Tray View (Windows 11 style)

struct SystemTrayView: View {
    let format: ClockFormat
    let showDate: Bool

    @State private var currentTime = Date()
    @State private var isHovered = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 1) {
            // Time
            Text(currentTime, format: format.dateStyle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)

            // Date (optional)
            if showDate {
                Text(currentTime, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(isHovered ? 0.1 : 0.05))
        )
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - Show Desktop Button (Windows 11 style - thin bar at edge)

struct ShowDesktopButton: View {
    let isHorizontal: Bool

    @Environment(AppState.self) private var appState
    @State private var isHovered = false

    var body: some View {
        Button(
            action: { appState.toggleShowDesktop() },
            label: {
                if isHorizontal {
                    // Vertical bar for horizontal taskbar
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.primary.opacity(isHovered ? 0.3 : 0.15))
                        .frame(width: 4, height: 24)
                } else {
                    // Horizontal bar for vertical taskbar
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.primary.opacity(isHovered ? 0.3 : 0.15))
                        .frame(width: 24, height: 4)
                }
            }
        )
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .help(String(localized: "Show Desktop"))
    }
}

// MARK: - Visual Effect View

/// NSVisualEffectView wrapper for SwiftUI blur background
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Preview

#Preview {
    TaskbarView()
        .environment(AppState())
        .frame(height: 52)
}
