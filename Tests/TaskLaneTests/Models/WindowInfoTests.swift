import Testing
import CoreGraphics
import Foundation
@testable import TaskLane

@Suite("WindowInfo Tests")
struct WindowInfoTests {

    // MARK: - Helpers

    /// Create a valid dictionary for WindowInfo initialization
    private func createWindowDict(
        windowID: CGWindowID = 123,
        ownerPID: pid_t = 456,
        ownerName: String = "TestApp",
        layer: Int = 0,
        name: String? = "Test Window",
        isOnScreen: Bool = true,
        alpha: CGFloat = 1.0,
        bounds: [String: CGFloat]? = ["X": 0, "Y": 0, "Width": 800, "Height": 600]
    ) -> CFDictionary {
        var dict: [CFString: Any] = [
            kCGWindowNumber: windowID,
            kCGWindowOwnerPID: ownerPID,
            kCGWindowOwnerName: ownerName,
            kCGWindowLayer: layer
        ]

        if let name = name {
            dict[kCGWindowName] = name
        }
        dict[kCGWindowIsOnscreen] = isOnScreen
        dict[kCGWindowAlpha] = alpha

        if let bounds = bounds {
            dict[kCGWindowBounds] = bounds
        }

        return dict as CFDictionary
    }

    // MARK: - Initialization

    @Test("WindowInfo initializes from valid dictionary")
    func initFromValidDict() {
        let dict = createWindowDict()
        let info = WindowInfo(from: dict)

        #expect(info != nil)
        #expect(info?.id == 123)
        #expect(info?.ownerPID == 456)
        #expect(info?.ownerName == "TestApp")
        #expect(info?.layer == 0)
        #expect(info?.name == "Test Window")
        #expect(info?.isOnScreen == true)
        #expect(info?.alpha == 1.0)
    }

    @Test("WindowInfo fails with missing window number")
    func failsWithMissingWindowNumber() {
        let dict: [CFString: Any] = [
            kCGWindowOwnerPID: 456 as pid_t,
            kCGWindowOwnerName: "TestApp",
            kCGWindowLayer: 0
        ]

        let info = WindowInfo(from: dict as CFDictionary)
        #expect(info == nil)
    }

    @Test("WindowInfo fails with missing owner PID")
    func failsWithMissingOwnerPID() {
        let dict: [CFString: Any] = [
            kCGWindowNumber: 123 as CGWindowID,
            kCGWindowOwnerName: "TestApp",
            kCGWindowLayer: 0
        ]

        let info = WindowInfo(from: dict as CFDictionary)
        #expect(info == nil)
    }

    @Test("WindowInfo fails with missing owner name")
    func failsWithMissingOwnerName() {
        let dict: [CFString: Any] = [
            kCGWindowNumber: 123 as CGWindowID,
            kCGWindowOwnerPID: 456 as pid_t,
            kCGWindowLayer: 0
        ]

        let info = WindowInfo(from: dict as CFDictionary)
        #expect(info == nil)
    }

    @Test("WindowInfo fails with missing layer")
    func failsWithMissingLayer() {
        let dict: [CFString: Any] = [
            kCGWindowNumber: 123 as CGWindowID,
            kCGWindowOwnerPID: 456 as pid_t,
            kCGWindowOwnerName: "TestApp"
        ]

        let info = WindowInfo(from: dict as CFDictionary)
        #expect(info == nil)
    }

    // MARK: - Optional Fields

    @Test("WindowInfo handles missing name")
    func handlesNilName() {
        let dict = createWindowDict(name: nil)
        let info = WindowInfo(from: dict)

        #expect(info != nil)
        #expect(info?.name == nil)
    }

    @Test("WindowInfo defaults isOnScreen to false")
    func defaultsIsOnScreenToFalse() {
        let dict: [CFString: Any] = [
            kCGWindowNumber: 123 as CGWindowID,
            kCGWindowOwnerPID: 456 as pid_t,
            kCGWindowOwnerName: "TestApp",
            kCGWindowLayer: 0
        ]
        // Don't include isOnScreen

        let info = WindowInfo(from: dict as CFDictionary)
        #expect(info?.isOnScreen == false)
    }

    @Test("WindowInfo defaults alpha to 1.0")
    func defaultsAlphaToOne() {
        let dict: [CFString: Any] = [
            kCGWindowNumber: 123 as CGWindowID,
            kCGWindowOwnerPID: 456 as pid_t,
            kCGWindowOwnerName: "TestApp",
            kCGWindowLayer: 0
        ]
        // Don't include alpha

        let info = WindowInfo(from: dict as CFDictionary)
        #expect(info?.alpha == 1.0)
    }

    @Test("WindowInfo defaults bounds to zero")
    func defaultsBoundsToZero() {
        let dict = createWindowDict(bounds: nil)
        let info = WindowInfo(from: dict)

        #expect(info?.bounds == .zero)
    }

    // MARK: - Bounds Parsing

    @Test("WindowInfo parses bounds correctly")
    func parsesBounds() {
        let dict = createWindowDict(bounds: ["X": 100, "Y": 200, "Width": 800, "Height": 600])
        let info = WindowInfo(from: dict)

        #expect(info?.bounds.origin.x == 100)
        #expect(info?.bounds.origin.y == 200)
        #expect(info?.bounds.width == 800)
        #expect(info?.bounds.height == 600)
    }

    // MARK: - Display Name

    @Test("displayName returns name when available")
    func displayNameReturnsName() {
        let dict = createWindowDict(name: "My Window")
        let info = WindowInfo(from: dict)!

        #expect(info.displayName == "My Window")
    }

    @Test("displayName returns fallback when name is nil")
    func displayNameFallbackForNil() {
        let dict = createWindowDict(windowID: 999, name: nil)
        let info = WindowInfo(from: dict)!

        #expect(info.displayName.contains("999"))
    }

    @Test("displayName returns fallback when name is empty")
    func displayNameFallbackForEmpty() {
        let dict = createWindowDict(windowID: 888, name: "")
        let info = WindowInfo(from: dict)!

        #expect(info.displayName.contains("888"))
    }

    // MARK: - isNormalWindow

    @Test("isNormalWindow returns true for layer 0, on screen, sufficient size")
    func isNormalWindowTrue() {
        let dict = createWindowDict(
            layer: 0,
            isOnScreen: true,
            bounds: ["X": 0, "Y": 0, "Width": 800, "Height": 600]
        )
        let info = WindowInfo(from: dict)!

        #expect(info.isNormalWindow == true)
    }

    @Test("isNormalWindow returns false for non-zero layer")
    func isNormalWindowFalseForNonZeroLayer() {
        let dict = createWindowDict(layer: 1)
        let info = WindowInfo(from: dict)!

        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false when not on screen")
    func isNormalWindowFalseWhenOffScreen() {
        let dict = createWindowDict(isOnScreen: false)
        let info = WindowInfo(from: dict)!

        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false for small width")
    func isNormalWindowFalseForSmallWidth() {
        let dict = createWindowDict(bounds: ["X": 0, "Y": 0, "Width": 40, "Height": 600])
        let info = WindowInfo(from: dict)!

        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow returns false for small height")
    func isNormalWindowFalseForSmallHeight() {
        let dict = createWindowDict(bounds: ["X": 0, "Y": 0, "Width": 800, "Height": 40])
        let info = WindowInfo(from: dict)!

        #expect(info.isNormalWindow == false)
    }

    @Test("isNormalWindow boundary test at exactly 50")
    func isNormalWindowBoundary() {
        // Width and height must be > 50, not >= 50
        let dict50 = createWindowDict(bounds: ["X": 0, "Y": 0, "Width": 50, "Height": 50])
        let info50 = WindowInfo(from: dict50)!
        #expect(info50.isNormalWindow == false)

        let dict51 = createWindowDict(bounds: ["X": 0, "Y": 0, "Width": 51, "Height": 51])
        let info51 = WindowInfo(from: dict51)!
        #expect(info51.isNormalWindow == true)
    }

    // MARK: - Identifiable

    @Test("WindowInfo id is the window ID")
    func identifiable() {
        let dict = createWindowDict(windowID: 12345)
        let info = WindowInfo(from: dict)!

        #expect(info.id == 12345)
    }
}
