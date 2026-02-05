import AppKit
@testable import TaskLane

actor MockThumbnailProvider: ThumbnailProviderProtocol {
    // MARK: - Configurable State

    var thumbnails: [CGWindowID: NSImage] = [:]
    var shouldReturnNil = false

    // MARK: - Call Tracking

    var captureCallCount = 0
    var clearCacheCallCount = 0
    var invalidateCallCount = 0
    var lastCapturedWindowID: CGWindowID?
    var lastInvalidatedWindowID: CGWindowID?

    // MARK: - Protocol Implementation

    func capture(windowID: CGWindowID) async -> NSImage? {
        captureCallCount += 1
        lastCapturedWindowID = windowID
        if shouldReturnNil {
            return nil
        }
        return thumbnails[windowID] ?? createPlaceholderImage()
    }

    func clearCache() async {
        clearCacheCallCount += 1
        thumbnails.removeAll()
    }

    func invalidate(windowID: CGWindowID) async {
        invalidateCallCount += 1
        lastInvalidatedWindowID = windowID
        thumbnails.removeValue(forKey: windowID)
    }

    // MARK: - Test Helpers

    func setThumbnail(_ image: NSImage, for windowID: CGWindowID) {
        thumbnails[windowID] = image
    }

    func reset() {
        thumbnails.removeAll()
        shouldReturnNil = false
        captureCallCount = 0
        clearCacheCallCount = 0
        invalidateCallCount = 0
        lastCapturedWindowID = nil
        lastInvalidatedWindowID = nil
    }

    private func createPlaceholderImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 100, height: 100))
        image.lockFocus()
        NSColor.gray.setFill()
        NSRect(x: 0, y: 0, width: 100, height: 100).fill()
        image.unlockFocus()
        return image
    }
}
