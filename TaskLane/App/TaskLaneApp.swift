import SwiftUI

/// Main application entry point
@main
struct TaskLaneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No SwiftUI scenes - settings window is managed by AppDelegate
        WindowGroup {
            EmptyView()
        }
        .handlesExternalEvents(matching: Set())
    }
}
