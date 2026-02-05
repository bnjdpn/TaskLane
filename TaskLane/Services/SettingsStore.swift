import Foundation

/// Persists settings to UserDefaults
@MainActor
final class SettingsStore {
    private let defaults: UserDefaults
    private let key = "TaskLaneSettings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Load settings from UserDefaults
    func load() -> TaskLaneSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(TaskLaneSettings.self, from: data)
        else {
            return TaskLaneSettings()
        }
        return settings
    }

    /// Save settings to UserDefaults
    func save(_ settings: TaskLaneSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }

    /// Reset settings to defaults
    func reset() {
        defaults.removeObject(forKey: key)
    }

    /// Add a pinned app
    func addPinnedApp(_ bundleID: String) {
        var settings = load()
        if !settings.pinnedAppBundleIDs.contains(bundleID) {
            settings.pinnedAppBundleIDs.append(bundleID)
            save(settings)
        }
    }

    /// Remove a pinned app
    func removePinnedApp(_ bundleID: String) {
        var settings = load()
        settings.pinnedAppBundleIDs.removeAll { $0 == bundleID }
        save(settings)
    }

    /// Move a pinned app to a new position
    func movePinnedApp(from source: Int, to destination: Int) {
        var settings = load()
        guard source >= 0, source < settings.pinnedAppBundleIDs.count,
              destination >= 0, destination <= settings.pinnedAppBundleIDs.count
        else { return }

        let item = settings.pinnedAppBundleIDs.remove(at: source)
        let adjustedDestination = destination > source ? destination - 1 : destination
        settings.pinnedAppBundleIDs.insert(item, at: adjustedDestination)
        save(settings)
    }
}
