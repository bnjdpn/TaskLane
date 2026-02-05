import Testing
import AppKit
@testable import TaskLane

@Suite("TaskbarItem Tests")
struct TaskbarItemTests {

    // MARK: - Initialization

    @Test("TaskbarItem initializes with all properties")
    func initialization() {
        let icon = NSImage()
        let item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test App",
            icon: icon,
            isPinned: true,
            isRunning: true,
            windowCount: 3,
            processIdentifier: 1234
        )

        #expect(item.bundleIdentifier == "com.test.app")
        #expect(item.displayName == "Test App")
        #expect(item.isPinned == true)
        #expect(item.isRunning == true)
        #expect(item.windowCount == 3)
        #expect(item.processIdentifier == 1234)
    }

    @Test("TaskbarItem has default values for optional parameters")
    func defaultValues() {
        let item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item.windowCount == 0)
        #expect(item.processIdentifier == nil)
    }

    @Test("TaskbarItem generates unique UUID by default")
    func uniqueID() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item1.id != item2.id)
    }

    @Test("TaskbarItem accepts custom UUID")
    func customUUID() {
        let customID = UUID()
        let item = TaskbarItem(
            id: customID,
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item.id == customID)
    }

    // MARK: - Hashable

    @Test("TaskbarItem hash uses bundleIdentifier only")
    func hashUseBundleID() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 1",
            icon: NSImage(),
            isPinned: true,
            isRunning: true,
            windowCount: 5
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 2",
            icon: NSImage(),
            isPinned: false,
            isRunning: false,
            windowCount: 0
        )

        #expect(item1.hashValue == item2.hashValue)
    }

    @Test("Different bundleIdentifiers produce different hashes")
    func differentBundleIDsHaveDifferentHashes() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app1",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app2",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item1.hashValue != item2.hashValue)
    }

    @Test("Items with same bundleIdentifier but different UUIDs have same hash")
    func hashIgnoresUUID() {
        let item1 = TaskbarItem(
            id: UUID(),
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        let item2 = TaskbarItem(
            id: UUID(),
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item1.hashValue == item2.hashValue)
    }

    // MARK: - Equatable

    @Test("TaskbarItem equality uses bundleIdentifier only")
    func equalityUsesBundleID() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Different Name",
            icon: NSImage(),
            isPinned: true,
            isRunning: true,
            windowCount: 10
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Another Name",
            icon: NSImage(),
            isPinned: false,
            isRunning: false,
            windowCount: 0
        )

        #expect(item1 == item2)
    }

    @Test("Different bundleIdentifiers are not equal")
    func differentBundleIDsNotEqual() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app1",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app2",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item1 != item2)
    }

    @Test("Items with same bundleIdentifier but different UUIDs are equal")
    func equalityIgnoresUUID() {
        let item1 = TaskbarItem(
            id: UUID(),
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        let item2 = TaskbarItem(
            id: UUID(),
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item1 == item2)
    }

    @Test("Items with same bundleIdentifier but different processIdentifiers are equal")
    func equalityIgnoresProcessIdentifier() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: true,
            processIdentifier: 1234
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: true,
            processIdentifier: 5678
        )

        #expect(item1 == item2)
    }

    // MARK: - Mutability

    @Test("TaskbarItem mutable properties can be changed")
    func mutability() {
        var item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false,
            windowCount: 0
        )

        item.isPinned = true
        item.isRunning = true
        item.windowCount = 5

        #expect(item.isPinned == true)
        #expect(item.isRunning == true)
        #expect(item.windowCount == 5)
    }

    @Test("TaskbarItem processIdentifier can be updated")
    func processIdentifierMutability() {
        var item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false,
            processIdentifier: nil
        )

        item.processIdentifier = 9999
        #expect(item.processIdentifier == 9999)

        item.processIdentifier = nil
        #expect(item.processIdentifier == nil)
    }

    // MARK: - Set Behavior

    @Test("TaskbarItems work correctly in Set")
    func setOperations() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 1",
            icon: NSImage(),
            isPinned: true,
            isRunning: true
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 2",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        let item3 = TaskbarItem(
            bundleIdentifier: "com.other.app",
            displayName: "Other",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        var set = Set<TaskbarItem>()
        set.insert(item1)
        set.insert(item2)  // Same bundleID, should not add
        set.insert(item3)

        #expect(set.count == 2)
    }

    @Test("Set contains check works with bundleIdentifier")
    func setContains() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 1",
            icon: NSImage(),
            isPinned: true,
            isRunning: true
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Different Name",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        var set = Set<TaskbarItem>()
        set.insert(item1)

        #expect(set.contains(item2))
    }

    // MARK: - Dictionary Key Behavior

    @Test("TaskbarItems work correctly as Dictionary keys")
    func dictionaryKeyBehavior() {
        let item1 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 1",
            icon: NSImage(),
            isPinned: true,
            isRunning: true
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test 2",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        var dict: [TaskbarItem: Int] = [:]
        dict[item1] = 1
        dict[item2] = 2  // Should overwrite since same bundleID

        #expect(dict.count == 1)
        #expect(dict[item1] == 2)
    }

    // MARK: - Identifiable

    @Test("TaskbarItem conforms to Identifiable with UUID id")
    func identifiableConformance() {
        let item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        // Verify id is a UUID type
        let _: UUID = item.id
        #expect(item.id != UUID())  // Should be a valid non-nil UUID
    }

    // MARK: - Edge Cases

    @Test("TaskbarItem handles empty bundleIdentifier")
    func emptyBundleIdentifier() {
        let item = TaskbarItem(
            bundleIdentifier: "",
            displayName: "Unknown App",
            icon: NSImage(),
            isPinned: false,
            isRunning: true
        )

        #expect(item.bundleIdentifier == "")
    }

    @Test("TaskbarItem handles empty displayName")
    func emptyDisplayName() {
        let item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "",
            icon: NSImage(),
            isPinned: false,
            isRunning: false
        )

        #expect(item.displayName == "")
    }

    @Test("TaskbarItem handles negative windowCount")
    func negativeWindowCount() {
        let item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: false,
            windowCount: -1
        )

        #expect(item.windowCount == -1)
    }

    @Test("TaskbarItem handles zero processIdentifier")
    func zeroProcessIdentifier() {
        let item = TaskbarItem(
            bundleIdentifier: "com.test.app",
            displayName: "Test",
            icon: NSImage(),
            isPinned: false,
            isRunning: true,
            processIdentifier: 0
        )

        #expect(item.processIdentifier == 0)
    }

    @Test("Items with empty bundleIdentifiers are equal")
    func emptyBundleIdentifiersAreEqual() {
        let item1 = TaskbarItem(
            bundleIdentifier: "",
            displayName: "Unknown 1",
            icon: NSImage(),
            isPinned: false,
            isRunning: true
        )

        let item2 = TaskbarItem(
            bundleIdentifier: "",
            displayName: "Unknown 2",
            icon: NSImage(),
            isPinned: true,
            isRunning: false
        )

        #expect(item1 == item2)
        #expect(item1.hashValue == item2.hashValue)
    }
}
