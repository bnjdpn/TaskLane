import SwiftUI
import Testing
import ViewInspector
@testable import TaskLane

extension ClockView: Inspectable {}

@Suite("ClockView Tests")
struct ClockViewTests {

    @Test("ClockView renders with short format")
    @MainActor
    func rendersWithShortFormat() throws {
        let view = ClockView(format: .short)
        let inspected = try view.inspect()

        // Verify the view contains a Text element
        let text = try inspected.text()
        #expect(text != nil)
    }

    @Test("ClockView renders with medium format")
    @MainActor
    func rendersWithMediumFormat() throws {
        let view = ClockView(format: .medium)
        let inspected = try view.inspect()

        let text = try inspected.text()
        #expect(text != nil)
    }

    @Test("ClockView renders with full format")
    @MainActor
    func rendersWithFullFormat() throws {
        let view = ClockView(format: .full)
        let inspected = try view.inspect()

        let text = try inspected.text()
        #expect(text != nil)
    }

    @Test("ClockView has horizontal padding")
    @MainActor
    func hasHorizontalPadding() throws {
        let view = ClockView(format: .short)
        let inspected = try view.inspect()

        // ViewInspector can verify padding is applied
        let text = try inspected.text()
        let padding = try text.padding()
        #expect(padding != nil)
    }
}
