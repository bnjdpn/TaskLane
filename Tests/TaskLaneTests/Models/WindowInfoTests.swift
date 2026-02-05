import CoreGraphics
import Testing
@testable import TaskLane

@Suite("WindowInfo Tests")
struct WindowInfoTests {

    // MARK: - Display Name

    @Test("displayName returns window name when available")
    func displayNameWithName() {
        let info = createWindowInfo(name: "Document.txt - TextEdit")
        #expect(info.displayName == "Document.txt - TextEdit")
    }

    @Test("displayName returns fallback when name is nil")
    func displayNameWithoutName() {
        let info = createWindowInfo(name: nil)
        #expect(info.displayName.contains("Window"))
    }

    @Test("displayName returns fallback when name is empty")
    func displayNameWithEmptyName() {
        let info = createWindowInfo(name: "")
        #expect(info.displayName.contains("Window"))
    }

    // MARK: - isNormalWindow

    @Test("isNormalWindow returns true for standard windows")
    func isNormalWindowTrue() {
        let info = createWindowInfo(
            layer: 0,
            isOnScreen: true,
            bounds: CGRect(x: 0, y: 0, width: 800, height: 600)
        )
        #expect(info.isNormalWindow == true)
    }

    @Test("isNormalWindow returns false for non-zero layer")
    func isNormalWindowFalseLayer() {
        let info = createWindowInfo(
            layer: 1,
            isOnScreen: true,
            bounds: CGRect(x: 0, y: 0, width: 800, height: 600)
        )
        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false for off-screen windows")
    func isNormalWindowFalseOffScreen() {
        let info = createWindowInfo(
            layer: 0,
            isOnScreen: false,
            bounds: CGRect(x: 0, y: 0, width: 800, height: 600)
        )
        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false for small windows")
    func isNormalWindowFalseSmall() {
        let info = createWindowInfo(
            layer: 0,
            isOnScreen: true,
            bounds: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false for narrow windows")
    func isNormalWindowFalseNarrow() {
        let info = createWindowInfo(
            layer: 0,
            isOnScreen: true,
            bounds: CGRect(x: 0, y: 0, width: 40, height: 600)
        )
        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false for short windows")
    func isNormalWindowFalseShort() {
        let info = createWindowInfo(
            layer: 0,
            isOnScreen: true,
            bounds: CGRect(x: 0, y: 0, width: 800, height: 40)
        )
        #expect(info.isNormalWindow == false)
    }

    // MARK: - Identifiable

    @Test("WindowInfo id is the window ID")
    func identifiable() {
        let info = createWindowInfo(windowID: 12345)
        #expect(info.id == 12345)
    }

    // MARK: - Sendable

    @Test("WindowInfo is Sendable")
    func sendable() async {
        let info = createWindowInfo()

        // Test that we can pass it across actor boundaries
        let result = await Task.detached {
            return info.displayName
        }.value

        #expect(result == info.displayName)
    }

    // MARK: - Helper Methods

    private func createWindowInfo(
        windowID: CGWindowID = 1,
        ownerPID: pid_t = 100,
        ownerName: String = "TestApp",
        name: String? = "Test Window",
        layer: Int = 0,
        isOnScreen: Bool = true,
        bounds: CGRect = CGRect(x: 0, y: 0, width: 800, height: 600),
        alpha: CGFloat = 1.0
    ) -> WindowInfo {
        // Create a WindowInfo directly using a fake dictionary
        // Since init?(from:) is the only initializer, we need to work around it
        WindowInfoTestHelper.create(
            id: windowID,
            ownerPID: ownerPID,
            ownerName: ownerName,
            name: name,
            layer: layer,
            isOnScreen: isOnScreen,
            bounds: bounds,
            alpha: alpha
        )
    }
}

// MARK: - Test Helper

/// Helper to create WindowInfo for testing without going through CFDictionary
enum WindowInfoTestHelper {
    static func create(
        id: CGWindowID,
        ownerPID: pid_t,
        ownerName: String,
        name: String?,
        layer: Int,
        isOnScreen: Bool,
        bounds: CGRect,
        alpha: CGFloat
    ) -> WindowInfo {
        // Create a CFDictionary that matches what CGWindowListCopyWindowInfo returns
        let dict: [CFString: Any] = [
            kCGWindowNumber: id,
            kCGWindowOwnerPID: ownerPID,
            kCGWindowOwnerName: ownerName,
            kCGWindowName: name as Any,
            kCGWindowLayer: layer,
            kCGWindowIsOnscreen: isOnScreen,
            kCGWindowAlpha: alpha,
            kCGWindowBounds: [
                "X": bounds.origin.x,
                "Y": bounds.origin.y,
                "Width": bounds.width,
                "Height": bounds.height
            ]
        ]

        return WindowInfo(from: dict as CFDictionary)!
    }
}
