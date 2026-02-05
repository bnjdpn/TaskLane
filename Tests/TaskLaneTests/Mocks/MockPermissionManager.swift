import AppKit
@testable import TaskLane

@MainActor
final class MockPermissionManager: PermissionManagerProtocol {
    // MARK: - Configurable State

    var screenRecordingPermission = false
    var accessibilityPermission = false

    // MARK: - Call Tracking

    var hasScreenRecordingCallCount = 0
    var requestScreenRecordingCallCount = 0
    var openScreenRecordingSettingsCallCount = 0
    var hasAccessibilityPermissionCallCount = 0
    var requestAccessibilityPermissionCallCount = 0

    // MARK: - Protocol Implementation

    func hasScreenRecording() -> Bool {
        hasScreenRecordingCallCount += 1
        return screenRecordingPermission
    }

    func requestScreenRecording() {
        requestScreenRecordingCallCount += 1
    }

    func openScreenRecordingSettings() {
        openScreenRecordingSettingsCallCount += 1
    }

    func hasAccessibilityPermission() -> Bool {
        hasAccessibilityPermissionCallCount += 1
        return accessibilityPermission
    }

    func requestAccessibilityPermission() {
        requestAccessibilityPermissionCallCount += 1
    }

    // MARK: - Test Helpers

    func grantAllPermissions() {
        screenRecordingPermission = true
        accessibilityPermission = true
    }

    func denyAllPermissions() {
        screenRecordingPermission = false
        accessibilityPermission = false
    }

    func reset() {
        screenRecordingPermission = false
        accessibilityPermission = false
        hasScreenRecordingCallCount = 0
        requestScreenRecordingCallCount = 0
        openScreenRecordingSettingsCallCount = 0
        hasAccessibilityPermissionCallCount = 0
        requestAccessibilityPermissionCallCount = 0
    }
}
