import AppKit
import Testing
@testable import TaskLane

@Suite("TaskbarItem Tests")
struct TaskbarItemTests {

    // MARK: - Initialization

    @Test("TaskbarItem initializes with all properties")
    func initialization() {
        let icon = NSImage()
        let item = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: true,
            isRunning: true,
            windowCount: 3,
            processIdentifier: 1234
        )

        #expect(item.bundleIdentifier == "com.example.app")
        #expect(item.displayName == "Example App")
        #expect(item.isPinned == true)
        #expect(item.isRunning == true)
        #expect(item.windowCount == 3)
        #expect(item.processIdentifier == 1234)
    }

    @Test("TaskbarItem initializes with default values")
    func initializationDefaults() {
        let icon = NSImage()
        let item = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )

        #expect(item.windowCount == 0)
        #expect(item.processIdentifier == nil)
    }

    // MARK: - Identifiable

    @Test("TaskbarItem generates unique IDs")
    func uniqueIds() {
        let icon = NSImage()
        let item1 = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )
        let item2 = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )

        #expect(item1.id != item2.id)
    }

    // MARK: - Hashable

    @Test("TaskbarItem hashes by bundleIdentifier")
    func hashByBundleIdentifier() {
        let icon = NSImage()
        let item1 = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )
        let item2 = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Different Name",
            icon: icon,
            isPinned: true,
            isRunning: true
        )

        #expect(item1.hashValue == item2.hashValue)
    }

    // MARK: - Equatable

    @Test("TaskbarItem equality is based on bundleIdentifier")
    func equalityByBundleIdentifier() {
        let icon = NSImage()
        let item1 = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )
        let item2 = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Different Name",
            icon: icon,
            isPinned: true,
            isRunning: true,
            windowCount: 5
        )

        #expect(item1 == item2)
    }

    @Test("TaskbarItem inequality for different bundleIdentifiers")
    func inequalityDifferentBundleIdentifiers() {
        let icon = NSImage()
        let item1 = TaskbarItem(
            bundleIdentifier: "com.example.app1",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )
        let item2 = TaskbarItem(
            bundleIdentifier: "com.example.app2",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )

        #expect(item1 != item2)
    }

    // MARK: - Mutability

    @Test("TaskbarItem allows updating mutable properties")
    func mutability() {
        let icon = NSImage()
        var item = TaskbarItem(
            bundleIdentifier: "com.example.app",
            displayName: "Example App",
            icon: icon,
            isPinned: false,
            isRunning: false
        )

        item.isPinned = true
        item.isRunning = true
        item.windowCount = 5

        #expect(item.isPinned == true)
        #expect(item.isRunning == true)
        #expect(item.windowCount == 5)
    }
}
