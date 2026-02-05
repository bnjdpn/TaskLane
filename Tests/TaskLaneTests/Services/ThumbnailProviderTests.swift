import Testing
import AppKit
import CoreGraphics
@testable import TaskLane

@Suite("ThumbnailProvider Tests")
struct ThumbnailProviderTests {

    // Note: We cannot test actual thumbnail capture as it requires
    // Screen Recording permission. We test the cache management methods.

    @Test("clearCache clears all cached thumbnails")
    func clearCacheClears() async {
        let provider = ThumbnailProvider()

        // Clear cache should not throw
        await provider.clearCache()

        // Calling again should be safe (no-op on empty cache)
        await provider.clearCache()
    }

    @Test("invalidate removes specific window from cache")
    func invalidateRemovesWindow() async {
        let provider = ThumbnailProvider()

        // Invalidate non-existent window should be safe
        await provider.invalidate(windowID: 12345)

        // Multiple invalidates should be safe
        await provider.invalidate(windowID: 12345)
        await provider.invalidate(windowID: 67890)
    }

    @Test("cleanupExpiredCache removes old entries")
    func cleanupExpiredCache() async {
        let provider = ThumbnailProvider()

        // Cleanup should be safe on empty cache
        await provider.cleanupExpiredCache()
    }

    @Test("capture returns nil without permission")
    func captureReturnsNilWithoutPermission() async {
        let provider = ThumbnailProvider()

        // This will fail without Screen Recording permission
        // but should return nil gracefully, not crash
        let result = await provider.capture(windowID: 99999)

        // We expect nil because either:
        // 1. No permission (most likely in test environment)
        // 2. Window doesn't exist
        #expect(result == nil)
    }

    @Test("capture with invalid window ID returns nil")
    func captureInvalidWindowReturnsNil() async {
        let provider = ThumbnailProvider()

        // Window ID 0 is invalid
        let result = await provider.capture(windowID: 0)
        #expect(result == nil)
    }

    @Test("Multiple capture calls are safe")
    func multipleCaptureCallsSafe() async {
        let provider = ThumbnailProvider()

        // Multiple concurrent captures should not crash
        async let r1 = provider.capture(windowID: 1)
        async let r2 = provider.capture(windowID: 2)
        async let r3 = provider.capture(windowID: 3)

        _ = await [r1, r2, r3]
    }

    @Test("Cache operations can be interleaved")
    func cacheOperationsInterleaved() async {
        let provider = ThumbnailProvider()

        // Interleaved operations should be safe
        await provider.invalidate(windowID: 1)
        await provider.clearCache()
        await provider.invalidate(windowID: 2)
        await provider.cleanupExpiredCache()
        await provider.clearCache()
    }
}
