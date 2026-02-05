import AppKit
import SwiftUI

/// Custom NSPanel that stays on top and behaves like a taskbar
final class TaskbarPanel: NSPanel {

    // MARK: - Properties

    private let targetScreen: NSScreen

    // MARK: - Initialization

    init(screen: NSScreen) {
        self.targetScreen = screen

        super.init(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        configurePanel()
    }

    // MARK: - Configuration

    private func configurePanel() {
        // Taskbar behavior - stay above normal windows but below alerts
        level = .statusBar

        // Collection behavior for spaces and fullscreen
        collectionBehavior = [
            .canJoinAllSpaces,      // Show on all spaces/desktops
            .fullScreenAuxiliary,   // Don't hide in fullscreen
            .stationary,            // Don't move when spaces change
            .ignoresCycle           // Don't include in window cycling (Cmd+`)
        ]

        // Appearance
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // Title bar
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // Behavior
        hidesOnDeactivate = false
        isMovable = false
        isMovableByWindowBackground = false

        // Mouse events
        acceptsMouseMovedEvents = true
        ignoresMouseEvents = false

        // Animation
        animationBehavior = .none
    }

    // MARK: - NSWindow Overrides

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    // MARK: - Positioning

    /// Position the panel at the specified edge of the screen
    func position(at edge: TaskbarPosition, size: CGFloat) {
        // Use full screen frame for full-width coverage
        let screenFrame = targetScreen.frame
        var frame: NSRect

        switch edge {
        case .bottom:
            frame = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: screenFrame.width,
                height: size
            )
        case .top:
            frame = NSRect(
                x: screenFrame.minX,
                y: screenFrame.maxY - size,
                width: screenFrame.width,
                height: size
            )
        case .left:
            frame = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: size,
                height: screenFrame.height
            )
        case .right:
            frame = NSRect(
                x: screenFrame.maxX - size,
                y: screenFrame.minY,
                width: size,
                height: screenFrame.height
            )
        }

        setFrame(frame, display: true, animate: false)
    }

    /// Update panel for the current screen configuration
    func updateForScreen() {
        // Re-apply position with current settings
        // This is called when screen parameters change
    }

    // MARK: - Content

    /// Set the SwiftUI content view
    func setContent<Content: View>(_ view: Content) {
        contentView = NSHostingView(rootView: view)
    }
}

// MARK: - NSScreen Extension

extension NSScreen {
    /// Unique identifier for the screen
    var identifier: String {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return "unknown-\(hash)"
        }
        return String(screenNumber)
    }

    /// Check if this is the primary display
    var isPrimary: Bool {
        self == NSScreen.main
    }
}
