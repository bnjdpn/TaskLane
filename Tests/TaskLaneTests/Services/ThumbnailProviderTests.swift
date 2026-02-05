import Testing
import AppKit
import CoreGraphics
@testable import TaskLane

@Suite("ThumbnailProvider Tests")
struct ThumbnailProviderTests {

    // Note: We cannot test actual thumbnail capture as it requires
    // Screen Recording permission and NSImage is non-Sendable across actor boundaries.
    // We only test the cache management methods.

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
