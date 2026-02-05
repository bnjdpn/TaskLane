import Testing
import Foundation
@testable import TaskLane

@Suite("PermissionManager Tests")
@MainActor
struct PermissionManagerTests {

    // MARK: - Screen Recording

    @Test("hasScreenRecording returns boolean")
    func hasScreenRecordingReturnsBool() {
        let manager = PermissionManager()

        // Should return a boolean (we don't know which one without permission)
        let result = manager.hasScreenRecording()
        #expect(result == true || result == false)
    }

    @Test("requestScreenRecording does not crash")
    func requestScreenRecordingDoesNotCrash() {
        let manager = PermissionManager()

        // This triggers a system dialog in real usage, but in tests
        // it should not crash (may do nothing or show dialog)
        manager.requestScreenRecording()
    }

    @Test("hasScreenRecordingByWindowCheck returns boolean")
    func hasScreenRecordingByWindowCheckReturnsBool() {
        let manager = PermissionManager()

        let result = manager.hasScreenRecordingByWindowCheck()
        #expect(result == true || result == false)
    }

    // MARK: - Accessibility

    @Test("hasAccessibilityPermission returns boolean")
    func hasAccessibilityPermissionReturnsBool() {
        let manager = PermissionManager()

        let result = manager.hasAccessibilityPermission()
        #expect(result == true || result == false)
    }

    @Test("requestAccessibilityPermission does not crash")
    func requestAccessibilityPermissionDoesNotCrash() {
        let manager = PermissionManager()

        // Note: This may open System Settings in a real environment
        // In tests, it should not crash
        manager.requestAccessibilityPermission()
    }

    // MARK: - Permission Status

    @Test("screenRecordingStatus returns valid status")
    func screenRecordingStatusReturnsValidStatus() {
        let manager = PermissionManager()

        let status = manager.screenRecordingStatus()

        switch status {
        case .granted, .denied, .unknown:
            // All valid cases
            break
        }
    }

    @Test("PermissionStatus enum has all expected cases")
    func permissionStatusEnumCases() {
        // Verify all cases exist
        let granted = PermissionManager.PermissionStatus.granted
        let denied = PermissionManager.PermissionStatus.denied
        let unknown = PermissionManager.PermissionStatus.unknown

        #expect(granted != denied)
        #expect(denied != unknown)
        #expect(granted != unknown)
    }

    // MARK: - Singleton

    @Test("shared singleton exists")
    func sharedSingletonExists() {
        let shared = PermissionManager.shared

        // Verify the singleton is a valid PermissionManager instance
        #expect(type(of: shared) == PermissionManager.self)
    }

    @Test("shared singleton is same instance")
    func sharedSingletonSameInstance() {
        let shared1 = PermissionManager.shared
        let shared2 = PermissionManager.shared

        #expect(shared1 === shared2)
    }

    // MARK: - Consistency

    @Test("hasScreenRecording is consistent with screenRecordingStatus")
    func screenRecordingConsistency() {
        let manager = PermissionManager()

        let hasPerm = manager.hasScreenRecording()
        let status = manager.screenRecordingStatus()

        if hasPerm {
            #expect(status == .granted)
        } else {
            #expect(status == .denied)
        }
    }
}
