import SwiftUI

/// Appearance settings tab
struct AppearanceSettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        Form {
            // Theme Section
            Section {
                Picker(String(localized: "Appearance"), selection: $state.settings.appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.localizedName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text(String(localized: "Theme"))
            }

            // Background Section
            Section {
                Toggle(
                    String(localized: "Use blur effect"),
                    isOn: $state.settings.useBlurEffect
                )

                if !state.settings.useBlurEffect {
                    ColorPicker(
                        String(localized: "Background color"),
                        selection: Binding(
                            get: { state.settings.accentColor.color },
                            set: { state.settings.accentColor = CodableColor($0) }
                        )
                    )
                }
            } header: {
                Text(String(localized: "Background"))
            }

            // Window Previews Section
            Section {
                Toggle(
                    String(localized: "Show window previews"),
                    isOn: $state.settings.showWindowPreviews
                )

                if state.settings.showWindowPreviews {
                    HStack {
                        Text(String(localized: "Preview size"))
                        Slider(
                            value: $state.settings.previewSize,
                            in: 100...300,
                            step: 20
                        )
                        Text("\(Int(state.settings.previewSize))px")
                            .monospacedDigit()
                            .frame(width: 50)
                    }

                    HStack {
                        Text(String(localized: "Hover delay"))
                        Slider(
                            value: $state.settings.hoverDelay,
                            in: 0.1...1.0,
                            step: 0.1
                        )
                        Text(String(format: "%.1fs", state.settings.hoverDelay))
                            .monospacedDigit()
                            .frame(width: 40)
                    }
                }
            } header: {
                Text(String(localized: "Window Previews"))
            } footer: {
                if !appState.hasScreenRecordingPermission {
                    Label(
                        String(localized: "Window previews require Screen Recording permission."),
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
            }

            // Layout Section
            Section {
                Toggle(
                    String(localized: "Center icons"),
                    isOn: $state.settings.centerIcons
                )
            } header: {
                Text(String(localized: "Layout"))
            } footer: {
                Text(String(localized: "When enabled, app icons are centered in the taskbar like Windows 11."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Clock Section
            Section {
                Toggle(
                    String(localized: "Show date"),
                    isOn: $state.settings.showDate
                )
            } header: {
                Text(String(localized: "Clock"))
            } footer: {
                Text(String(localized: "Display the date below the time in the system tray."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Labels Section
            Section {
                Toggle(
                    String(localized: "Show app labels"),
                    isOn: $state.settings.showLabels
                )
            } header: {
                Text(String(localized: "Labels"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    AppearanceSettingsView()
        .environment(AppState())
        .frame(width: 500, height: 400)
}
