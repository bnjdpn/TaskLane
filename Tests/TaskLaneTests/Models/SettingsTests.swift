import Testing
import SwiftUI
@testable import TaskLane

@Suite("TaskLaneSettings Tests")
struct SettingsTests {

    // MARK: - Default Values

    @Test("Default settings have expected values")
    func defaultSettings() {
        let settings = TaskLaneSettings()

        #expect(settings.position == .bottom)
        #expect(settings.height == 48)
        #expect(settings.showOnAllScreens == false)
        #expect(settings.primaryScreenOnly == true)
        #expect(settings.appearanceMode == .system)
        #expect(settings.useBlurEffect == true)
        #expect(settings.cornerRadius == 0)
        #expect(settings.showWindowPreviews == true)
        #expect(settings.previewSize == 200)
        #expect(settings.hoverDelay == 0.3)
        #expect(settings.pinnedAppBundleIDs.isEmpty)
        #expect(settings.groupWindows == .always)
        #expect(settings.showLabels == false)
        #expect(settings.showClock == true)
        #expect(settings.clockFormat == .short)
        #expect(settings.showDate == true)
        #expect(settings.centerIcons == true)
        #expect(settings.launchAtLogin == false)
        #expect(settings.autoHide == false)
        #expect(settings.autoHideDelay == 1.0)
    }

    // MARK: - Codable

    @Test("Settings encode and decode correctly")
    func codable() throws {
        var settings = TaskLaneSettings()
        settings.position = .top
        settings.height = 64
        settings.pinnedAppBundleIDs = ["com.apple.Safari", "com.apple.mail"]
        settings.showClock = false
        settings.autoHide = true

        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TaskLaneSettings.self, from: data)

        #expect(decoded.position == .top)
        #expect(decoded.height == 64)
        #expect(decoded.pinnedAppBundleIDs == ["com.apple.Safari", "com.apple.mail"])
        #expect(decoded.showClock == false)
        #expect(decoded.autoHide == true)
    }

    // MARK: - Equatable

    @Test("Settings equality works correctly")
    func equality() {
        let settings1 = TaskLaneSettings()
        var settings2 = TaskLaneSettings()

        #expect(settings1 == settings2)

        settings2.height = 100
        #expect(settings1 != settings2)
    }

    // MARK: - Computed Properties

    @Test("Effective height returns height for horizontal positions")
    func effectiveHeightHorizontal() {
        var settings = TaskLaneSettings()
        settings.height = 60

        settings.position = .bottom
        #expect(settings.effectiveHeight == 60)

        settings.position = .top
        #expect(settings.effectiveHeight == 60)
    }

    @Test("Effective height returns height for vertical positions")
    func effectiveHeightVertical() {
        var settings = TaskLaneSettings()
        settings.height = 60

        settings.position = .left
        #expect(settings.effectiveHeight == 60)

        settings.position = .right
        #expect(settings.effectiveHeight == 60)
    }
}

// MARK: - TaskbarPosition Tests

@Suite("TaskbarPosition Tests")
struct TaskbarPositionTests {

    @Test("isHorizontal returns true for bottom and top")
    func isHorizontalTrue() {
        #expect(TaskbarPosition.bottom.isHorizontal == true)
        #expect(TaskbarPosition.top.isHorizontal == true)
    }

    @Test("isHorizontal returns false for left and right")
    func isHorizontalFalse() {
        #expect(TaskbarPosition.left.isHorizontal == false)
        #expect(TaskbarPosition.right.isHorizontal == false)
    }

    @Test("All cases are iterable")
    func allCases() {
        let cases = TaskbarPosition.allCases
        #expect(cases.count == 4)
        #expect(cases.contains(.bottom))
        #expect(cases.contains(.top))
        #expect(cases.contains(.left))
        #expect(cases.contains(.right))
    }
}

// MARK: - AppearanceMode Tests

@Suite("AppearanceMode Tests")
struct AppearanceModeTests {

    @Test("All cases are iterable")
    func allCases() {
        let cases = AppearanceMode.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.system))
        #expect(cases.contains(.light))
        #expect(cases.contains(.dark))
    }
}

// MARK: - GroupingMode Tests

@Suite("GroupingMode Tests")
struct GroupingModeTests {

    @Test("All cases are iterable")
    func allCases() {
        let cases = GroupingMode.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.always))
        #expect(cases.contains(.never))
        #expect(cases.contains(.automatic))
    }
}

// MARK: - ClockFormat Tests

@Suite("ClockFormat Tests")
struct ClockFormatTests {

    @Test("All cases are iterable")
    func allCases() {
        let cases = ClockFormat.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.short))
        #expect(cases.contains(.medium))
        #expect(cases.contains(.full))
    }
}

// MARK: - CodableColor Tests

@Suite("CodableColor Tests")
struct CodableColorTests {

    @Test("CodableColor initializes with components")
    func initWithComponents() {
        let codable = CodableColor(red: 1.0, green: 0.5, blue: 0.25, opacity: 0.8)

        #expect(codable.red == 1.0)
        #expect(codable.green == 0.5)
        #expect(codable.blue == 0.25)
        #expect(codable.opacity == 0.8)
    }

    @Test("CodableColor converts to Color")
    func convertsToColor() {
        let codable = CodableColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0)
        let color = codable.color

        // Color comparison is tricky, just verify it doesn't crash
        #expect(color != Color.clear)
    }

    @Test("CodableColor encodes and decodes correctly")
    func codable() throws {
        let original = CodableColor(red: 0.5, green: 0.6, blue: 0.7, opacity: 0.9)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CodableColor.self, from: data)

        #expect(decoded.red == 0.5)
        #expect(decoded.green == 0.6)
        #expect(decoded.blue == 0.7)
        #expect(decoded.opacity == 0.9)
    }

    @Test("CodableColor equality works")
    func equality() {
        let color1 = CodableColor(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
        let color2 = CodableColor(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
        let color3 = CodableColor(red: 0.6, green: 0.5, blue: 0.5, opacity: 1.0)

        #expect(color1 == color2)
        #expect(color1 != color3)
    }
}
