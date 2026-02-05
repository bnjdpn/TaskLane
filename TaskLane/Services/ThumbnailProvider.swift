import AppKit
@preconcurrency import ScreenCaptureKit

/// Captures window thumbnails using ScreenCaptureKit
actor ThumbnailProvider: ThumbnailProviderProtocol {
    // MARK: - Types

    private struct CachedThumbnail {
        let image: NSImage
        let timestamp: Date
    }

    // MARK: - Properties

    private var cache: [CGWindowID: CachedThumbnail] = [:]
    private let cacheTimeout: TimeInterval = 5.0
    private let maxSize = CGSize(width: 300, height: 200)

    // MARK: - Public Methods

    /// Capture a thumbnail for a specific window
    func capture(windowID: CGWindowID) async -> NSImage? {
        // Check cache first
        if let cached = cache[windowID],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout {
            return cached.image
        }

        do {
            // Get shareable content
            let content = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: true
            )

            // Find the window
            guard let window = content.windows.first(where: { $0.windowID == windowID }) else {
                return nil
            }

            // Create filter for single window
            let filter = SCContentFilter(desktopIndependentWindow: window)

            // Configure for thumbnail capture
            let config = SCStreamConfiguration()
            config.width = Int(maxSize.width * 2)  // Retina
            config.height = Int(maxSize.height * 2)
            config.scalesToFit = true
            config.showsCursor = false

            // Capture single frame
            let cgImage = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: config
            )

            let nsImage = NSImage(
                cgImage: cgImage,
                size: NSSize(
                    width: CGFloat(cgImage.width) / 2,
                    height: CGFloat(cgImage.height) / 2
                )
            )

            // Cache result
            cache[windowID] = CachedThumbnail(
                image: nsImage,
                timestamp: Date()
            )

            return nsImage

        } catch {
            // Permission denied or other error
            return nil
        }
    }

    /// Clear all cached thumbnails
    func clearCache() {
        cache.removeAll()
    }

    /// Invalidate a specific cached thumbnail
    func invalidate(windowID: CGWindowID) {
        cache.removeValue(forKey: windowID)
    }

    /// Clean up expired cache entries
    func cleanupExpiredCache() {
        let now = Date()
        cache = cache.filter { _, value in
            now.timeIntervalSince(value.timestamp) < cacheTimeout
        }
    }
}
