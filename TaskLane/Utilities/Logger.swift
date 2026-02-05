import Foundation
import os.log

/// Centralized logging for TaskLane
enum Log {
    /// Subsystem identifier for all TaskLane logs
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.tasklane"

    /// Logger for general app events
    static let app = Logger(subsystem: subsystem, category: "App")

    /// Logger for permission-related events
    static let permissions = Logger(subsystem: subsystem, category: "Permissions")

    /// Logger for window monitoring events
    static let windows = Logger(subsystem: subsystem, category: "Windows")

    /// Logger for taskbar UI events
    static let taskbar = Logger(subsystem: subsystem, category: "Taskbar")
}
