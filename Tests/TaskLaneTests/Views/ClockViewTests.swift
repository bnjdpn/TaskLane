import SwiftUI
import Testing
// ViewInspector temporarily disabled due to CI crash (signal 11)
// import ViewInspector
@testable import TaskLane

// extension ClockView: Inspectable {}

// ViewInspector tests disabled temporarily - crash on CI with signal 11
// TODO: Investigate ViewInspector compatibility with CI environment
@Suite("ClockView Tests", .disabled("ViewInspector crashes on CI"))
struct ClockViewTests {

    @Test("ClockView renders with short format")
    @MainActor
    func rendersWithShortFormat() throws {
        // Test disabled
    }

    @Test("ClockView renders with medium format")
    @MainActor
    func rendersWithMediumFormat() throws {
        // Test disabled
    }

    @Test("ClockView renders with full format")
    @MainActor
    func rendersWithFullFormat() throws {
        // Test disabled
    }

    @Test("ClockView has horizontal padding")
    @MainActor
    func hasHorizontalPadding() throws {
        // Test disabled
    }
}
