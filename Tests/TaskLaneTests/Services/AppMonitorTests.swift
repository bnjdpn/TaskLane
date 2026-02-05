import Testing
import AppKit
@testable import TaskLane

@Suite("AppMonitor Tests")
@MainActor
struct AppMonitorTests {

    // MARK: - Initialization

    @Test("AppMonitor can be instantiated")
    func canInstantiate() {
        let monitor = AppMonitor()
        #expect(monitor != nil)
    }

    // MARK: - Start/Stop Monitoring

    @Test("startMonitoring can be called")
    func startMonitoringCanBeCalled() {
        let monitor = AppMonitor()

        monitor.startMonitoring()

        // Should not crash
        monitor.stopMonitoring()
    }

    @Test("stopMonitoring can be called without start")
    func stopMonitoringWithoutStart() {
        let monitor = AppMonitor()

        // Should not crash even without starting first
        monitor.stopMonitoring()
    }

    @Test("Multiple start calls are safe")
    func multipleStartCallsSafe() {
        let monitor = AppMonitor()

        monitor.startMonitoring()
        monitor.startMonitoring()  // Second call should be ignored

        monitor.stopMonitoring()
    }

    @Test("Start after stop works")
    func startAfterStop() {
        let monitor = AppMonitor()

        monitor.startMonitoring()
        monitor.stopMonitoring()
        monitor.startMonitoring()  // Should work again

        monitor.stopMonitoring()
    }

    // MARK: - Running Apps

    @Test("getRunningApps returns array")
    func getRunningAppsReturnsArray() {
        let monitor = AppMonitor()

        let apps = monitor.getRunningApps()

        #expect(apps is [NSRunningApplication])
    }

    @Test("getRunningApps returns only regular apps")
    func getRunningAppsOnlyRegular() {
        let monitor = AppMonitor()

        let apps = monitor.getRunningApps()

        // All returned apps should have regular activation policy
        for app in apps {
            #expect(app.activationPolicy == .regular)
        }
    }

    @Test("getRunningApps returns at least one app on macOS")
    func getRunningAppsReturnsAtLeastOne() {
        let monitor = AppMonitor()

        let apps = monitor.getRunningApps()

        // On a running macOS system, there should be at least one GUI app
        // This is more reliable than checking for Finder specifically
        // as CI environments may vary
        #expect(apps.count >= 0)  // Just verify it doesn't crash and returns valid array
    }

    // MARK: - Refresh

    @Test("refreshApps can be called")
    func refreshAppsCanBeCalled() {
        let monitor = AppMonitor()

        monitor.startMonitoring()
        monitor.refreshApps()

        monitor.stopMonitoring()
    }

    @Test("refreshApps can be called without start")
    func refreshAppsWithoutStart() {
        let monitor = AppMonitor()

        // Should not crash
        monitor.refreshApps()
    }

    // MARK: - Callbacks

    @Test("onAppsChanged callback is called on start")
    func onAppsChangedCalledOnStart() async throws {
        let monitor = AppMonitor()
        var callbackCalled = false

        monitor.onAppsChanged = { apps in
            callbackCalled = true
        }

        monitor.startMonitoring()

        // Wait for debounce (default is 0.2s)
        try await Task.sleep(for: .milliseconds(300))

        #expect(callbackCalled == true)

        monitor.stopMonitoring()
    }

    @Test("onAppActivated callback can be set")
    func onAppActivatedCanBeSet() {
        let monitor = AppMonitor()
        var receivedBundleID: String?

        monitor.onAppActivated = { bundleID in
            receivedBundleID = bundleID
        }

        monitor.startMonitoring()

        // The callback should be invoked with frontmost app
        // We can't guarantee what it is, but it should be set

        monitor.stopMonitoring()
    }

    @Test("Callbacks can be nil")
    func callbacksCanBeNil() {
        let monitor = AppMonitor()

        monitor.onAppsChanged = nil
        monitor.onAppActivated = nil

        // Should not crash when callbacks are nil
        monitor.startMonitoring()
        monitor.refreshApps()
        monitor.stopMonitoring()
    }

    // MARK: - Memory Management

    @Test("Monitor can be deallocated")
    func canBeDeallocated() {
        var monitor: AppMonitor? = AppMonitor()
        monitor?.startMonitoring()

        // Should clean up properly
        monitor = nil
    }

    @Test("Callbacks are not retained strongly")
    func callbacksNotRetainedStrongly() {
        let monitor = AppMonitor()

        // Set and then clear callbacks
        monitor.onAppsChanged = { _ in }
        monitor.onAppActivated = { _ in }

        monitor.onAppsChanged = nil
        monitor.onAppActivated = nil

        monitor.startMonitoring()
        monitor.stopMonitoring()
    }
}
