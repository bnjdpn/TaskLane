import AppKit
import SwiftUI

/// Custom NSPanel that stays on top and behaves like a taskbar
final class TaskbarPanel: NSPanel {

    // MARK: - Properties

    private let targetScreen: NSScreen

    // MARK: - Auto-hide State

    private var isHidden = false
    private var hideTimer: Timer?
    private var trackingArea: NSTrackingArea?
    private var edgeTrackingWindow: NSWindow?

    /// Auto-hide settings - updated by controller
    var autoHideEnabled = false {
        didSet {
            if autoHideEnabled {
                setupMouseTracking()
            } else {
                removeMouseTracking()
                showTaskbar(animated: false)
            }
        }
    }
    var autoHideDelay: TimeInterval = 1.0
    private var currentPosition: TaskbarPosition = .bottom
    private var currentSize: CGFloat = 48

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
        currentPosition = edge
        currentSize = size

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

        // Update tracking if auto-hide is enabled
        if autoHideEnabled {
            setupMouseTracking()
        }
    }

    /// Update panel for the current screen configuration
    func updateForScreen() {
        // Re-apply position with current settings
        // This is called when screen parameters change
    }

    // MARK: - Auto-hide Mouse Tracking

    private func setupMouseTracking() {
        removeMouseTracking()

        guard let contentView else { return }

        // Track mouse inside the panel
        let area = NSTrackingArea(
            rect: contentView.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        contentView.addTrackingArea(area)
        trackingArea = area

        // Create edge detection window for when panel is hidden
        setupEdgeDetectionWindow()
    }

    private func removeMouseTracking() {
        if let area = trackingArea, let contentView {
            contentView.removeTrackingArea(area)
        }
        trackingArea = nil

        hideTimer?.invalidate()
        hideTimer = nil

        edgeTrackingWindow?.orderOut(nil)
        edgeTrackingWindow = nil
    }

    private func setupEdgeDetectionWindow() {
        edgeTrackingWindow?.orderOut(nil)

        let screenFrame = targetScreen.frame
        let edgeSize: CGFloat = 4  // Thin strip at screen edge

        var edgeFrame: NSRect
        switch currentPosition {
        case .bottom:
            edgeFrame = NSRect(x: screenFrame.minX, y: screenFrame.minY,
                               width: screenFrame.width, height: edgeSize)
        case .top:
            edgeFrame = NSRect(x: screenFrame.minX, y: screenFrame.maxY - edgeSize,
                               width: screenFrame.width, height: edgeSize)
        case .left:
            edgeFrame = NSRect(x: screenFrame.minX, y: screenFrame.minY,
                               width: edgeSize, height: screenFrame.height)
        case .right:
            edgeFrame = NSRect(x: screenFrame.maxX - edgeSize, y: screenFrame.minY,
                               width: edgeSize, height: screenFrame.height)
        }

        let window = NSWindow(
            contentRect: edgeFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver  // Above everything
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Create tracking view
        let trackingView = EdgeTrackingView(onMouseEntered: { [weak self] in
            self?.showTaskbar(animated: true)
        })
        window.contentView = trackingView

        edgeTrackingWindow = window
        // Only show edge window when panel is hidden
        if isHidden {
            window.orderFrontRegardless()
        }
    }

    // MARK: - Mouse Events

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard autoHideEnabled else { return }

        hideTimer?.invalidate()
        hideTimer = nil

        if isHidden {
            showTaskbar(animated: true)
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard autoHideEnabled else { return }

        scheduleHide()
    }

    private func scheduleHide() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: autoHideDelay, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.hideTaskbar(animated: true)
            }
        }
    }

    // MARK: - Show/Hide Animation

    func hideTaskbar(animated: Bool) {
        guard !isHidden else { return }
        isHidden = true

        let screenFrame = targetScreen.frame
        var hiddenFrame = frame

        // Slide off screen
        switch currentPosition {
        case .bottom:
            hiddenFrame.origin.y = screenFrame.minY - frame.height + 1
        case .top:
            hiddenFrame.origin.y = screenFrame.maxY - 1
        case .left:
            hiddenFrame.origin.x = screenFrame.minX - frame.width + 1
        case .right:
            hiddenFrame.origin.x = screenFrame.maxX - 1
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.animator().setFrame(hiddenFrame, display: true)
            }
        } else {
            setFrame(hiddenFrame, display: true)
        }

        // Show edge detection window
        edgeTrackingWindow?.orderFrontRegardless()
    }

    func showTaskbar(animated: Bool) {
        guard isHidden else { return }
        isHidden = false

        // Hide edge detection window
        edgeTrackingWindow?.orderOut(nil)

        let screenFrame = targetScreen.frame
        var visibleFrame = frame

        // Restore to visible position
        switch currentPosition {
        case .bottom:
            visibleFrame.origin.y = screenFrame.minY
        case .top:
            visibleFrame.origin.y = screenFrame.maxY - currentSize
        case .left:
            visibleFrame.origin.x = screenFrame.minX
        case .right:
            visibleFrame.origin.x = screenFrame.maxX - currentSize
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.animator().setFrame(visibleFrame, display: true)
            }
        } else {
            setFrame(visibleFrame, display: true)
        }
    }

    // MARK: - Cleanup

    func cleanupAutoHide() {
        removeMouseTracking()
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

// MARK: - Edge Tracking View

/// Invisible view at screen edge that detects mouse entry to show hidden taskbar
private final class EdgeTrackingView: NSView {
    private var trackingArea: NSTrackingArea?
    private let onMouseEntered: () -> Void

    init(onMouseEntered: @escaping () -> Void) {
        self.onMouseEntered = onMouseEntered
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let existing = trackingArea {
            removeTrackingArea(existing)
        }

        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        onMouseEntered()
    }
}
