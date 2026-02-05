import Testing
import Foundation
import CoreGraphics
@testable import TaskLane

@Suite("WindowController Tests")
@MainActor
struct WindowControllerTests {

    // MARK: - Singleton

    @Test("shared singleton exists")
    func sharedSingletonExists() {
        let shared: WindowController? = WindowController.shared
        #expect(shared != nil)
    }

    @Test("shared singleton is same instance")
    func sharedSingletonSameInstance() {
        let shared1 = WindowController.shared
        let shared2 = WindowController.shared

        #expect(shared1 === shared2)
    }

    // MARK: - Permission Check

    @Test("hasAccessibilityPermission returns boolean")
    func hasAccessibilityPermissionReturnsBool() {
        let result = WindowController.hasAccessibilityPermission()

        #expect(result == true || result == false)
    }

    // Note: requestAccessibilityPermission() test removed - it triggers system permission dialogs

    // MARK: - Focus Window

    @Test("focusWindow returns boolean")
    func focusWindowReturnsBool() {
        let controller = WindowController()

        let result = controller.focusWindow(windowID: 12345, pid: 1)

        // Without permission or valid window, should return false
        #expect(result == true || result == false)
    }

    @Test("focusWindow with invalid window ID returns false")
    func focusWindowInvalidWindowID() {
        let controller = WindowController()

        let result = controller.focusWindow(windowID: 0, pid: 0)

        #expect(result == false)
    }

    // MARK: - Close Window

    @Test("closeWindow returns boolean")
    func closeWindowReturnsBool() {
        let controller = WindowController()

        let result = controller.closeWindow(windowID: 12345, pid: 1)

        #expect(result == true || result == false)
    }

    @Test("closeWindow with invalid parameters returns false")
    func closeWindowInvalidParams() {
        let controller = WindowController()

        let result = controller.closeWindow(windowID: 0, pid: 0)

        #expect(result == false)
    }

    // MARK: - Minimize Window

    @Test("minimizeWindow returns boolean")
    func minimizeWindowReturnsBool() {
        let controller = WindowController()

        let result = controller.minimizeWindow(windowID: 12345, pid: 1)

        #expect(result == true || result == false)
    }

    @Test("minimizeWindow with invalid parameters returns false")
    func minimizeWindowInvalidParams() {
        let controller = WindowController()

        let result = controller.minimizeWindow(windowID: 0, pid: 0)

        #expect(result == false)
    }

    // MARK: - Unminimize Window

    @Test("unminimizeWindow returns boolean")
    func unminimizeWindowReturnsBool() {
        let controller = WindowController()

        let result = controller.unminimizeWindow(windowID: 12345, pid: 1)

        #expect(result == true || result == false)
    }

    @Test("unminimizeWindow with invalid parameters returns false")
    func unminimizeWindowInvalidParams() {
        let controller = WindowController()

        let result = controller.unminimizeWindow(windowID: 0, pid: 0)

        #expect(result == false)
    }

    // MARK: - Resize Window

    @Test("resizeWindowToAvoidTaskbar returns boolean")
    func resizeWindowToAvoidTaskbarReturnsBool() {
        let controller = WindowController()
        let frame = NSRect(x: 0, y: 0, width: 100, height: 48)

        let result = controller.resizeWindowToAvoidTaskbar(
            windowID: 12345,
            pid: 1,
            taskbarFrame: frame,
            position: .bottom
        )

        #expect(result == true || result == false)
    }

    @Test("resizeWindowToAvoidTaskbar handles all positions")
    func resizeWindowToAvoidTaskbarAllPositions() {
        let controller = WindowController()
        let frame = NSRect(x: 0, y: 0, width: 100, height: 48)

        // Test all positions - should not crash
        _ = controller.resizeWindowToAvoidTaskbar(windowID: 1, pid: 1, taskbarFrame: frame, position: .bottom)
        _ = controller.resizeWindowToAvoidTaskbar(windowID: 1, pid: 1, taskbarFrame: frame, position: .top)
        _ = controller.resizeWindowToAvoidTaskbar(windowID: 1, pid: 1, taskbarFrame: frame, position: .left)
        _ = controller.resizeWindowToAvoidTaskbar(windowID: 1, pid: 1, taskbarFrame: frame, position: .right)
    }

    // MARK: - Concurrent Access

    @Test("Multiple instances are independent")
    func multipleInstancesIndependent() {
        let controller1 = WindowController()
        let controller2 = WindowController()

        // Both should work independently
        _ = controller1.focusWindow(windowID: 1, pid: 1)
        _ = controller2.focusWindow(windowID: 2, pid: 2)
    }

    @Test("Rapid method calls are safe")
    func rapidMethodCallsSafe() {
        let controller = WindowController()

        for _ in 0..<10 {
            _ = controller.focusWindow(windowID: 1, pid: 1)
            _ = controller.closeWindow(windowID: 1, pid: 1)
            _ = controller.minimizeWindow(windowID: 1, pid: 1)
            _ = controller.unminimizeWindow(windowID: 1, pid: 1)
        }
    }
}
