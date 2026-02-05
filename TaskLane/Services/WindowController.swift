import AppKit
import ApplicationServices

/// Controls windows using macOS Accessibility APIs (requires Accessibility permission)
@MainActor
final class WindowController {

    // MARK: - Singleton

    static let shared = WindowController()

    private init() {}

    // MARK: - Permission Check

    /// Check if we have Accessibility permission
    static func hasAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }

    /// Request Accessibility permission (opens System Settings)
    nonisolated static func requestAccessibilityPermission() {
        let key = "AXTrustedCheckOptionPrompt" as CFString
        let options = [key: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Window Control

    /// Focus a specific window by its window ID
    func focusWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        guard Self.hasAccessibilityPermission() else {
            Self.requestAccessibilityPermission()
            return false
        }

        let appElement = AXUIElementCreateApplication(pid)

        // Get all windows for this app
        var windowsValue: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)

        guard result == .success,
              let windows = windowsValue as? [AXUIElement] else {
            return false
        }

        // Find the window matching our windowID
        for window in windows {
            if getWindowID(for: window) == windowID {
                // Raise and focus the window
                AXUIElementSetAttributeValue(window, kAXMainAttribute as CFString, true as CFTypeRef)
                AXUIElementPerformAction(window, kAXRaiseAction as CFString)

                // Activate the application
                if let app = NSRunningApplication(processIdentifier: pid) {
                    app.activate()
                }

                return true
            }
        }

        return false
    }

    /// Close a specific window
    func closeWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        guard Self.hasAccessibilityPermission() else {
            Self.requestAccessibilityPermission()
            return false
        }

        let appElement = AXUIElementCreateApplication(pid)

        var windowsValue: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)

        guard result == .success,
              let windows = windowsValue as? [AXUIElement] else {
            return false
        }

        for window in windows {
            if getWindowID(for: window) == windowID {
                // Get close button
                var closeButtonValue: CFTypeRef?
                let closeResult = AXUIElementCopyAttributeValue(window, kAXCloseButtonAttribute as CFString, &closeButtonValue)

                if closeResult == .success, let closeButton = closeButtonValue {
                    AXUIElementPerformAction(closeButton as! AXUIElement, kAXPressAction as CFString)
                    return true
                }
            }
        }

        return false
    }

    /// Minimize a specific window
    func minimizeWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        guard Self.hasAccessibilityPermission() else {
            Self.requestAccessibilityPermission()
            return false
        }

        let appElement = AXUIElementCreateApplication(pid)

        var windowsValue: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)

        guard result == .success,
              let windows = windowsValue as? [AXUIElement] else {
            return false
        }

        for window in windows {
            if getWindowID(for: window) == windowID {
                AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, true as CFTypeRef)
                return true
            }
        }

        return false
    }

    /// Unminimize (restore) a specific window
    func unminimizeWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        guard Self.hasAccessibilityPermission() else {
            Self.requestAccessibilityPermission()
            return false
        }

        let appElement = AXUIElementCreateApplication(pid)

        var windowsValue: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)

        guard result == .success,
              let windows = windowsValue as? [AXUIElement] else {
            return false
        }

        for window in windows {
            if getWindowID(for: window) == windowID {
                AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, false as CFTypeRef)

                // Also raise and focus it
                AXUIElementPerformAction(window, kAXRaiseAction as CFString)

                if let app = NSRunningApplication(processIdentifier: pid) {
                    app.activate()
                }

                return true
            }
        }

        return false
    }

    /// Resize a window to avoid the taskbar
    func resizeWindowToAvoidTaskbar(windowID: CGWindowID, pid: pid_t, taskbarFrame: NSRect, position: TaskbarPosition) -> Bool {
        guard Self.hasAccessibilityPermission() else { return false }

        let appElement = AXUIElementCreateApplication(pid)

        var windowsValue: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue)

        guard result == .success,
              let windows = windowsValue as? [AXUIElement] else {
            return false
        }

        for window in windows {
            if getWindowID(for: window) == windowID {
                // Get current window frame
                guard let currentFrame = getWindowFrame(for: window) else { continue }

                // Calculate new frame avoiding taskbar
                var newFrame = currentFrame

                switch position {
                case .bottom:
                    if currentFrame.minY < taskbarFrame.height {
                        newFrame.origin.y = taskbarFrame.height
                        if currentFrame.maxY > NSScreen.main?.frame.height ?? 0 {
                            newFrame.size.height = (NSScreen.main?.frame.height ?? 0) - taskbarFrame.height
                        }
                    }
                case .top:
                    let screenHeight = NSScreen.main?.frame.height ?? 0
                    if currentFrame.maxY > screenHeight - taskbarFrame.height {
                        newFrame.size.height = screenHeight - taskbarFrame.height - currentFrame.minY
                    }
                case .left:
                    if currentFrame.minX < taskbarFrame.width {
                        newFrame.origin.x = taskbarFrame.width
                    }
                case .right:
                    let screenWidth = NSScreen.main?.frame.width ?? 0
                    if currentFrame.maxX > screenWidth - taskbarFrame.width {
                        newFrame.size.width = screenWidth - taskbarFrame.width - currentFrame.minX
                    }
                }

                // Apply new frame if different
                if newFrame != currentFrame {
                    setWindowFrame(for: window, frame: newFrame)
                    return true
                }
            }
        }

        return false
    }

    // MARK: - Helper Methods

    private func getWindowID(for element: AXUIElement) -> CGWindowID? {
        var windowID: CGWindowID = 0
        let result = _AXUIElementGetWindow(element, &windowID)
        return result == .success ? windowID : nil
    }

    private func getWindowFrame(for element: AXUIElement) -> NSRect? {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?

        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeValue) == .success else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero

        AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)

        return NSRect(origin: NSPoint(x: position.x, y: position.y), size: size)
    }

    private func setWindowFrame(for element: AXUIElement, frame: NSRect) {
        var position = CGPoint(x: frame.origin.x, y: frame.origin.y)
        var size = CGSize(width: frame.width, height: frame.height)

        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, positionValue)
        }

        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, sizeValue)
        }
    }
}

// Private API to get window ID from AXUIElement
@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(_ element: AXUIElement, _ windowID: UnsafeMutablePointer<CGWindowID>) -> AXError
