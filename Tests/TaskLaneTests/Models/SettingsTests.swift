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
    }
}

// MARK: - Enum Tests

@Suite("AppearanceMode Tests")
struct AppearanceModeTests {
    @Test("All cases are iterable")
    func allCases() {
        #expect(AppearanceMode.allCases.count == 3)
    }
}

@Suite("GroupingMode Tests")
struct GroupingModeTests {
    @Test("All cases are iterable")
    func allCases() {
        #expect(GroupingMode.allCases.count == 3)
    }
}

@Suite("ClockFormat Tests")
struct ClockFormatTests {
    @Test("All cases are iterable")
    func allCases() {
        #expect(ClockFormat.allCases.count == 3)
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
