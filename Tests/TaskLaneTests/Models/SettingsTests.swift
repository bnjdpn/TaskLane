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

    @Test("localizedName exists for all positions")
    func localizedNames() {
        // Just verify they don't crash and return something
        _ = TaskbarPosition.bottom.localizedName
        _ = TaskbarPosition.top.localizedName
        _ = TaskbarPosition.left.localizedName
        _ = TaskbarPosition.right.localizedName
    }

    @Test("Raw values are correct strings")
    func rawValues() {
        #expect(TaskbarPosition.bottom.rawValue == "bottom")
        #expect(TaskbarPosition.top.rawValue == "top")
        #expect(TaskbarPosition.left.rawValue == "left")
        #expect(TaskbarPosition.right.rawValue == "right")
    }
}

// MARK: - Enum Tests

@Suite("AppearanceMode Tests")
struct AppearanceModeTests {
    @Test("All cases are iterable")
    func allCases() {
        #expect(AppearanceMode.allCases.count == 3)
    }

    @Test("localizedName exists for all modes")
    func localizedNames() {
        _ = AppearanceMode.system.localizedName
        _ = AppearanceMode.light.localizedName
        _ = AppearanceMode.dark.localizedName
    }

    @Test("Raw values are correct strings")
    func rawValues() {
        #expect(AppearanceMode.system.rawValue == "system")
        #expect(AppearanceMode.light.rawValue == "light")
        #expect(AppearanceMode.dark.rawValue == "dark")
    }
}

@Suite("GroupingMode Tests")
struct GroupingModeTests {
    @Test("All cases are iterable")
    func allCases() {
        #expect(GroupingMode.allCases.count == 3)
    }

    @Test("localizedName exists for all modes")
    func localizedNames() {
        _ = GroupingMode.always.localizedName
        _ = GroupingMode.never.localizedName
        _ = GroupingMode.automatic.localizedName
    }

    @Test("Raw values are correct strings")
    func rawValues() {
        #expect(GroupingMode.always.rawValue == "always")
        #expect(GroupingMode.never.rawValue == "never")
        #expect(GroupingMode.automatic.rawValue == "automatic")
    }
}

@Suite("ClockFormat Tests")
struct ClockFormatTests {
    @Test("All cases are iterable")
    func allCases() {
        #expect(ClockFormat.allCases.count == 3)
    }

    @Test("localizedName exists for all formats")
    func localizedNames() {
        _ = ClockFormat.short.localizedName
        _ = ClockFormat.medium.localizedName
        _ = ClockFormat.full.localizedName
    }

    @Test("Raw values are correct strings")
    func rawValues() {
        #expect(ClockFormat.short.rawValue == "short")
        #expect(ClockFormat.medium.rawValue == "medium")
        #expect(ClockFormat.full.rawValue == "full")
    }

    @Test("dateStyle returns valid format styles")
    func dateStyles() {
        // Verify dateStyle returns something usable
        let now = Date()
        _ = now.formatted(ClockFormat.short.dateStyle)
        _ = now.formatted(ClockFormat.medium.dateStyle)
        _ = now.formatted(ClockFormat.full.dateStyle)
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

    @Test("CodableColor initializes with default opacity")
    func initWithDefaultOpacity() {
        let codable = CodableColor(red: 0.5, green: 0.5, blue: 0.5)

        #expect(codable.opacity == 1.0)
    }

    @Test("CodableColor initializes from SwiftUI Color")
    func initFromColor() {
        let swiftUIColor = Color.red
        let codable = CodableColor(swiftUIColor)

        // Should have some values (exact values depend on color space conversion)
        #expect(codable.red >= 0 && codable.red <= 1)
        #expect(codable.green >= 0 && codable.green <= 1)
        #expect(codable.blue >= 0 && codable.blue <= 1)
        #expect(codable.opacity >= 0 && codable.opacity <= 1)
    }

    @Test("CodableColor converts back to SwiftUI Color")
    func colorProperty() {
        let codable = CodableColor(red: 0.5, green: 0.6, blue: 0.7, opacity: 0.9)
        let color = codable.color

        // The color property should return a valid Color
        #expect(color is Color)
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

    @Test("CodableColor round trip preserves values")
    func roundTrip() {
        let original = CodableColor(red: 0.25, green: 0.5, blue: 0.75, opacity: 1.0)
        let swiftUIColor = original.color
        let restored = CodableColor(swiftUIColor)

        // Values should be approximately equal (within floating point tolerance)
        #expect(abs(restored.red - original.red) < 0.01)
        #expect(abs(restored.green - original.green) < 0.01)
        #expect(abs(restored.blue - original.blue) < 0.01)
    }
}

// MARK: - TaskLaneSettings Computed Properties Tests

@Suite("TaskLaneSettings Computed Properties Tests")
struct SettingsComputedPropertiesTests {

    @Test("effectiveHeight returns height for horizontal positions")
    func effectiveHeightHorizontal() {
        var settings = TaskLaneSettings()
        settings.height = 64

        settings.position = .bottom
        #expect(settings.effectiveHeight == 64)

        settings.position = .top
        #expect(settings.effectiveHeight == 64)
    }

    @Test("effectiveHeight returns height for vertical positions")
    func effectiveHeightVertical() {
        var settings = TaskLaneSettings()
        settings.height = 64

        settings.position = .left
        #expect(settings.effectiveHeight == 64)

        settings.position = .right
        #expect(settings.effectiveHeight == 64)
    }

    @Test("effectiveWidth returns height for horizontal positions")
    func effectiveWidthHorizontal() {
        var settings = TaskLaneSettings()
        settings.height = 64

        settings.position = .bottom
        #expect(settings.effectiveWidth == 64)

        settings.position = .top
        #expect(settings.effectiveWidth == 64)
    }

    @Test("effectiveWidth returns height for vertical positions")
    func effectiveWidthVertical() {
        var settings = TaskLaneSettings()
        settings.height = 64

        settings.position = .left
        #expect(settings.effectiveWidth == 64)

        settings.position = .right
        #expect(settings.effectiveWidth == 64)
    }

    @Test("selectedScreenID can be nil")
    func selectedScreenIDNil() {
        let settings = TaskLaneSettings()
        #expect(settings.selectedScreenID == nil)
    }

    @Test("selectedScreenID can be set")
    func selectedScreenIDSet() {
        var settings = TaskLaneSettings()
        settings.selectedScreenID = "screen-123"
        #expect(settings.selectedScreenID == "screen-123")
    }

    @Test("accentColor has default value")
    func accentColorDefault() {
        let settings = TaskLaneSettings()
        // Default is accent color
        #expect(settings.accentColor.opacity == 1.0)
    }

    @Test("All settings properties are accessible")
    func allPropertiesAccessible() {
        var settings = TaskLaneSettings()

        // Position & Size
        settings.position = .left
        settings.height = 56

        // Screen Configuration
        settings.showOnAllScreens = true
        settings.primaryScreenOnly = false
        settings.selectedScreenID = "test"

        // Appearance
        settings.appearanceMode = .dark
        settings.useBlurEffect = false
        settings.accentColor = CodableColor(red: 1, green: 0, blue: 0, opacity: 1)
        settings.cornerRadius = 8

        // Window Previews
        settings.showWindowPreviews = false
        settings.previewSize = 250
        settings.hoverDelay = 0.5

        // Apps
        settings.pinnedAppBundleIDs = ["com.test"]
        settings.groupWindows = .never
        settings.showLabels = true

        // Clock
        settings.showClock = false
        settings.clockFormat = .full
        settings.showDate = false

        // Layout
        settings.centerIcons = false

        // Behavior
        settings.launchAtLogin = true
        settings.autoHide = true
        settings.autoHideDelay = 2.0

        #expect(settings.position == .left)
        #expect(settings.height == 56)
        #expect(settings.showOnAllScreens == true)
        #expect(settings.primaryScreenOnly == false)
        #expect(settings.selectedScreenID == "test")
        #expect(settings.appearanceMode == .dark)
        #expect(settings.useBlurEffect == false)
        #expect(settings.cornerRadius == 8)
        #expect(settings.showWindowPreviews == false)
        #expect(settings.previewSize == 250)
        #expect(settings.hoverDelay == 0.5)
        #expect(settings.pinnedAppBundleIDs == ["com.test"])
        #expect(settings.groupWindows == .never)
        #expect(settings.showLabels == true)
        #expect(settings.showClock == false)
        #expect(settings.clockFormat == .full)
        #expect(settings.showDate == false)
        #expect(settings.centerIcons == false)
        #expect(settings.launchAtLogin == true)
        #expect(settings.autoHide == true)
        #expect(settings.autoHideDelay == 2.0)
    }
}
