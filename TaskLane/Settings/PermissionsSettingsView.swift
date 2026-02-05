import SwiftUI

/// Permissions settings tab
struct PermissionsSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var screenRecordingStatus: PermissionStatus = .unknown

    enum PermissionStatus {
        case unknown
        case granted
        case denied
    }

    var body: some View {
        Form {
            // Screen Recording Section
            Section {
                screenRecordingRow
            } header: {
                Text(String(localized: "Screen Recording"))
            } footer: {
                Text(String(localized: "Screen Recording allows TaskLane to show window thumbnails and window names. Without this permission, you'll still see running apps but without previews."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Limitations Section
            Section {
                limitationsInfo
            } header: {
                Text(String(localized: "App Store Limitations"))
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            checkPermissions()
        }
    }

    // MARK: - Screen Recording Row

    @ViewBuilder
    private var screenRecordingRow: some View {
        HStack {
            // Status icon
            Image(systemName: statusIconName)
                .foregroundStyle(statusColor)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Screen Recording"))
                    .font(.headline)

                Text(statusDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if screenRecordingStatus != .granted {
                Button(String(localized: "Grant Access")) {
                    requestScreenRecording()
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Limitations Info

    @ViewBuilder
    private var limitationsInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Due to macOS App Store sandbox requirements, TaskLane has the following limitations:"))
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 8) {
                limitationRow(
                    icon: "hand.tap",
                    text: String(localized: "Clicking an app activates all its windows (cannot focus a specific window)")
                )

                limitationRow(
                    icon: "xmark.rectangle",
                    text: String(localized: "Cannot close or minimize individual windows")
                )

                limitationRow(
                    icon: "rectangle.arrowtriangle.2.outward",
                    text: String(localized: "No window arrangement or snapping features")
                )
            }

            Divider()

            Text(String(localized: "These are Apple's security restrictions for App Store apps. For full window control, consider apps distributed outside the App Store."))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func limitationRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Computed Properties

    private var statusIconName: String {
        switch screenRecordingStatus {
        case .granted: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    private var statusColor: Color {
        switch screenRecordingStatus {
        case .granted: return .green
        case .denied: return .red
        case .unknown: return .secondary
        }
    }

    private var statusDescription: String {
        switch screenRecordingStatus {
        case .granted:
            return String(localized: "Window previews and names are available.")
        case .denied:
            return String(localized: "Enable in System Settings to see window previews.")
        case .unknown:
            return String(localized: "Checking permission status...")
        }
    }

    // MARK: - Actions

    private func checkPermissions() {
        if PermissionManager.hasScreenRecording() {
            screenRecordingStatus = .granted
            appState.hasScreenRecordingPermission = true
        } else {
            screenRecordingStatus = .denied
            appState.hasScreenRecordingPermission = false
        }
    }

    private func requestScreenRecording() {
        PermissionManager.openScreenRecordingSettings()

        // Start polling for permission change using a Task
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if PermissionManager.hasScreenRecording() {
                    screenRecordingStatus = .granted
                    appState.hasScreenRecordingPermission = true
                    appState.refreshWindowList()
                    break
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PermissionsSettingsView()
        .environment(AppState())
        .frame(width: 500, height: 400)
}
