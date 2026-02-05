import SwiftUI

/// Individual app button in the taskbar - Windows 11 style
struct AppButtonView: View {
    let item: TaskbarItem

    @Environment(AppState.self) private var appState
    @State private var isHovered = false
    @State private var showPopover = false

    // MARK: - Computed Properties

    private var isActive: Bool {
        appState.activeAppBundleID == item.bundleIdentifier
    }

    private var buttonSize: CGFloat {
        appState.settings.height - 6
    }

    private var iconSize: CGFloat {
        buttonSize * 0.55
    }

    // MARK: - Body

    var body: some View {
        Button(action: handleClick) {
            buttonContent
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.08 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            handleHover(hovering)
        }
        .popover(isPresented: $showPopover, arrowEdge: popoverEdge) {
            WindowListPopover(item: item)
                .frame(minWidth: 240)
        }
        .help(item.displayName)
        .contextMenu {
            contextMenuContent
        }
    }

    // MARK: - Button Content

    @ViewBuilder
    private var buttonContent: some View {
        VStack(spacing: 0) {
            // Main button area
            ZStack {
                // Background - Windows 11 style rounded rectangle
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
                    .animation(.easeOut(duration: 0.15), value: isActive)

                // Icon with badge
                ZStack(alignment: .topTrailing) {
                    Image(nsImage: item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .opacity(item.isRunning ? 1.0 : 0.6)

                    // Window count badge
                    if item.windowCount > 1 {
                        windowCountBadge
                    }
                }
            }
            .frame(width: buttonSize, height: buttonSize - 6)

            // Running indicator - Windows 11 style bar
            runningIndicator
                .frame(height: 4)
        }
        .frame(width: buttonSize, height: buttonSize)
    }

    // MARK: - Background Color

    private var backgroundColor: Color {
        if isActive {
            return Color.primary.opacity(0.15)
        } else if isHovered {
            return Color.primary.opacity(0.08)
        }
        return Color.clear
    }

    // MARK: - Running Indicator (Windows 11 style bar)

    @ViewBuilder
    private var runningIndicator: some View {
        if item.isRunning {
            if isActive {
                // Active app: wider bar
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: 16, height: 3)
                    .animation(.easeOut(duration: 0.2), value: isActive)
            } else {
                // Running but not active: smaller pill
                Capsule()
                    .fill(Color.accentColor.opacity(0.7))
                    .frame(width: 6, height: 3)
                    .animation(.easeOut(duration: 0.2), value: isActive)
            }
        } else {
            // Not running: invisible spacer
            Color.clear
                .frame(width: 6, height: 3)
        }
    }

    // MARK: - Badge

    @ViewBuilder
    private var windowCountBadge: some View {
        Text("\(item.windowCount)")
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(minWidth: 16, minHeight: 16)
            .background(
                Circle()
                    .fill(Color.accentColor)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            )
            .offset(x: 6, y: -4)
    }

    // MARK: - Popover Edge

    private var popoverEdge: Edge {
        switch appState.settings.position {
        case .bottom: return .top
        case .top: return .bottom
        case .left: return .trailing
        case .right: return .leading
        }
    }

    // MARK: - Actions

    private func handleClick() {
        appState.activateApp(item)
    }

    private func handleHover(_ hovering: Bool) {
        isHovered = hovering

        if hovering && item.isRunning && item.windowCount > 0 {
            // Delay before showing popover
            DispatchQueue.main.asyncAfter(deadline: .now() + appState.settings.hoverDelay) {
                if isHovered && item.isRunning {
                    showPopover = true
                }
            }
        } else {
            showPopover = false
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        if item.isPinned {
            Button(String(localized: "Unpin from Taskbar")) {
                appState.unpinApp(item.bundleIdentifier)
            }
        } else if item.isRunning {
            Button(String(localized: "Pin to Taskbar")) {
                appState.pinApp(item.bundleIdentifier)
            }
        }

        Divider()

        if item.isRunning {
            Button(String(localized: "Quit \(item.displayName)")) {
                quitApp()
            }
        }
    }

    private func quitApp() {
        if let pid = item.processIdentifier,
           let app = NSRunningApplication(processIdentifier: pid) {
            app.terminate()
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        AppButtonView(item: TaskbarItem(
            bundleIdentifier: "com.apple.finder",
            displayName: "Finder",
            icon: NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)!,
            isPinned: true,
            isRunning: true,
            windowCount: 3
        ))

        AppButtonView(item: TaskbarItem(
            bundleIdentifier: "com.apple.safari",
            displayName: "Safari",
            icon: NSImage(systemSymbolName: "safari.fill", accessibilityDescription: nil)!,
            isPinned: false,
            isRunning: true,
            windowCount: 1
        ))

        AppButtonView(item: TaskbarItem(
            bundleIdentifier: "com.apple.mail",
            displayName: "Mail",
            icon: NSImage(systemSymbolName: "envelope.fill", accessibilityDescription: nil)!,
            isPinned: true,
            isRunning: false,
            windowCount: 0
        ))
    }
    .environment(AppState())
    .padding()
    .frame(height: 52)
    .background(Color(nsColor: .windowBackgroundColor))
}
