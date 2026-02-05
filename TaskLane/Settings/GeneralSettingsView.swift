import ServiceManagement
import SwiftUI

/// General settings tab
struct GeneralSettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        Form {
            // Position Section
            Section {
                Picker(String(localized: "Position"), selection: $state.settings.position) {
                    ForEach(TaskbarPosition.allCases, id: \.self) { pos in
                        Text(pos.localizedName).tag(pos)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Text(String(localized: "Size"))
                    Slider(
                        value: $state.settings.height,
                        in: 32...80,
                        step: 4
                    )
                    Text("\(Int(state.settings.height))pt")
                        .monospacedDigit()
                        .frame(width: 40)
                }
            } header: {
                Text(String(localized: "Taskbar Position"))
            }

            // Screen Section
            Section {
                Toggle(
                    String(localized: "Show on all screens"),
                    isOn: $state.settings.showOnAllScreens
                )

                if !state.settings.showOnAllScreens {
                    Toggle(
                        String(localized: "Primary screen only"),
                        isOn: $state.settings.primaryScreenOnly
                    )
                }
            } header: {
                Text(String(localized: "Screens"))
            }

            // Clock Section
            Section {
                Toggle(
                    String(localized: "Show clock"),
                    isOn: $state.settings.showClock
                )

                if state.settings.showClock {
                    Picker(String(localized: "Clock format"), selection: $state.settings.clockFormat) {
                        ForEach(ClockFormat.allCases, id: \.self) { fmt in
                            Text(fmt.localizedName).tag(fmt)
                        }
                    }
                }
            } header: {
                Text(String(localized: "Clock"))
            }

            // Behavior Section
            Section {
                Toggle(
                    String(localized: "Auto-hide taskbar"),
                    isOn: $state.settings.autoHide
                )

                if state.settings.autoHide {
                    HStack {
                        Text(String(localized: "Hide delay"))
                        Slider(
                            value: $state.settings.autoHideDelay,
                            in: 0.2...3.0,
                            step: 0.1
                        )
                        Text(String(format: "%.1fs", state.settings.autoHideDelay))
                            .monospacedDigit()
                            .frame(width: 40)
                    }

                    Text(String(localized: "Move your cursor to the screen edge to show the taskbar."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(String(localized: "Behavior"))
            }

            // Startup Section
            Section {
                LaunchAtLoginToggle()
            } header: {
                Text(String(localized: "Startup"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Launch at Login Toggle

struct LaunchAtLoginToggle: View {
    @State private var launchAtLogin = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(String(localized: "Launch at login"), isOn: $launchAtLogin)

            Text(String(localized: "Automatically start TaskLane when you log in."))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .onChange(of: launchAtLogin) { _, newValue in
            updateLoginItem(enabled: newValue)
        }
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func updateLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            // Revert toggle on failure
            launchAtLogin = !enabled
        }
    }
}

// MARK: - Preview

#Preview {
    GeneralSettingsView()
        .environment(AppState())
        .frame(width: 500, height: 400)
}
