import SwiftUI

/// Main settings window with tabs
struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label(String(localized: "General"), systemImage: "gear")
                }

            AppearanceSettingsView()
                .tabItem {
                    Label(String(localized: "Appearance"), systemImage: "paintbrush")
                }

            AppsSettingsView()
                .tabItem {
                    Label(String(localized: "Apps"), systemImage: "square.grid.2x2")
                }

            PermissionsSettingsView()
                .tabItem {
                    Label(String(localized: "Permissions"), systemImage: "lock.shield")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(AppState())
}
