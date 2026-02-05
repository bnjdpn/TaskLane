import SwiftUI

/// Apps/pinned apps settings tab
struct AppsSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showingAppPicker = false

    var body: some View {
        @Bindable var state = appState

        Form {
            // Pinned Apps Section
            Section {
                if state.settings.pinnedAppBundleIDs.isEmpty {
                    emptyPinnedAppsView
                } else {
                    pinnedAppsList
                }

                Button {
                    showingAppPicker = true
                } label: {
                    Label(String(localized: "Add App..."), systemImage: "plus")
                }
            } header: {
                Text(String(localized: "Pinned Apps"))
            } footer: {
                Text(String(localized: "Pinned apps always appear in the taskbar, even when not running."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Grouping Section
            Section {
                Picker(String(localized: "Group windows"), selection: $state.settings.groupWindows) {
                    ForEach(GroupingMode.allCases, id: \.self) { mode in
                        Text(mode.localizedName).tag(mode)
                    }
                }
            } header: {
                Text(String(localized: "Window Grouping"))
            }
        }
        .formStyle(.grouped)
        .padding()
        .fileImporter(
            isPresented: $showingAppPicker,
            allowedContentTypes: [.application],
            allowsMultipleSelection: false
        ) { result in
            handleAppSelection(result)
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyPinnedAppsView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "pin.slash")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text(String(localized: "No pinned apps"))
                    .foregroundStyle(.secondary)
                Text(String(localized: "Right-click apps in the taskbar to pin them."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            Spacer()
        }
    }

    // MARK: - Pinned Apps List

    @ViewBuilder
    private var pinnedAppsList: some View {
        ForEach(Array(appState.settings.pinnedAppBundleIDs.enumerated()), id: \.element) { index, bundleID in
            PinnedAppRow(bundleID: bundleID) {
                appState.unpinApp(bundleID)
            }
        }
        .onMove { source, destination in
            if let sourceIndex = source.first {
                appState.movePinnedApp(from: sourceIndex, to: destination)
            }
        }
    }

    // MARK: - App Selection

    private func handleAppSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result,
              let url = urls.first,
              let bundle = Bundle(url: url),
              let bundleID = bundle.bundleIdentifier
        else { return }

        appState.pinApp(bundleID)
    }
}

// MARK: - Pinned App Row

struct PinnedAppRow: View {
    let bundleID: String
    let onRemove: () -> Void

    @State private var appName: String = ""
    @State private var appIcon: NSImage?

    var body: some View {
        HStack(spacing: 12) {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "app")
                    .frame(width: 24, height: 24)
            }

            Text(appName.isEmpty ? bundleID : appName)
                .lineLimit(1)

            Spacer()

            Button(role: .destructive) {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            loadAppInfo()
        }
    }

    private func loadAppInfo() {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            appName = bundleID
            return
        }

        appIcon = NSWorkspace.shared.icon(forFile: url.path)
        appName = FileManager.default.displayName(atPath: url.path)
            .replacingOccurrences(of: ".app", with: "")
    }
}

// MARK: - Preview

#Preview {
    AppsSettingsView()
        .environment(AppState())
        .frame(width: 500, height: 400)
}
