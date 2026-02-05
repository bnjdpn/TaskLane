import Foundation
import SwiftUI

// MARK: - TaskbarPosition

/// Position of the taskbar on screen
enum TaskbarPosition: String, Codable, CaseIterable, Sendable {
    case bottom
    case top
    case left
    case right

    var isHorizontal: Bool {
        self == .bottom || self == .top
    }

    var localizedName: LocalizedStringKey {
        switch self {
        case .bottom: return "Bottom"
        case .top: return "Top"
        case .left: return "Left"
        case .right: return "Right"
        }
    }
}

// MARK: - AppearanceMode

/// Appearance mode for the taskbar
enum AppearanceMode: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark

    var localizedName: LocalizedStringKey {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - GroupingMode

/// How windows are grouped in the taskbar
enum GroupingMode: String, Codable, CaseIterable, Sendable {
    case always
    case never
    case automatic

    var localizedName: LocalizedStringKey {
        switch self {
        case .always: return "Always"
        case .never: return "Never"
        case .automatic: return "Automatic"
        }
    }
}

// MARK: - ClockFormat

/// Format for the clock display
enum ClockFormat: String, Codable, CaseIterable, Sendable {
    case short      // HH:mm
    case medium     // HH:mm:ss
    case full       // Day, HH:mm

    var localizedName: LocalizedStringKey {
        switch self {
        case .short: return "Short"
        case .medium: return "Medium"
        case .full: return "Full"
        }
    }

    var dateStyle: Date.FormatStyle {
        switch self {
        case .short:
            return .dateTime.hour().minute()
        case .medium:
            return .dateTime.hour().minute().second()
        case .full:
            return .dateTime.weekday(.abbreviated).hour().minute()
        }
    }
}

// MARK: - CodableColor

/// A Codable wrapper for SwiftUI Color
struct CodableColor: Codable, Equatable, Sendable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(_ color: Color) {
        // Default to accent color components
        self.red = 0.0
        self.green = 0.478
        self.blue = 1.0
        self.opacity = 1.0

        // Try to extract components from NSColor
        if let nsColor = NSColor(color).usingColorSpace(.sRGB) {
            self.red = Double(nsColor.redComponent)
            self.green = Double(nsColor.greenComponent)
            self.blue = Double(nsColor.blueComponent)
            self.opacity = Double(nsColor.alphaComponent)
        }
    }

    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - TaskLaneSettings

/// Main settings model for the application
struct TaskLaneSettings: Codable, Equatable, Sendable {
    // MARK: Position & Size
    var position: TaskbarPosition = .bottom
    var height: CGFloat = 48

    // MARK: Screen Configuration
    var showOnAllScreens: Bool = false
    var primaryScreenOnly: Bool = true
    var selectedScreenID: String?

    // MARK: Appearance
    var appearanceMode: AppearanceMode = .system
    var useBlurEffect: Bool = true
    var accentColor: CodableColor = CodableColor(Color.accentColor)
    var cornerRadius: CGFloat = 0

    // MARK: Window Previews
    var showWindowPreviews: Bool = true
    var previewSize: CGFloat = 200
    var hoverDelay: TimeInterval = 0.3

    // MARK: Apps
    var pinnedAppBundleIDs: [String] = []
    var groupWindows: GroupingMode = .always
    var showLabels: Bool = false

    // MARK: Clock
    var showClock: Bool = true
    var clockFormat: ClockFormat = .short
    var showDate: Bool = true

    // MARK: Layout
    var centerIcons: Bool = true

    // MARK: Behavior
    var launchAtLogin: Bool = false
    var autoHide: Bool = false
    var autoHideDelay: TimeInterval = 1.0

    // MARK: Computed Properties

    var effectiveHeight: CGFloat {
        position.isHorizontal ? height : height
    }

    var effectiveWidth: CGFloat {
        position.isHorizontal ? height : height
    }
}
