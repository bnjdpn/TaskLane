import SwiftUI

/// Popover showing window list for an app
struct WindowListPopover: View {
    let item: TaskbarItem

    @Environment(AppState.self) private var appState

    private var windows: [WindowInfo] {
        appState.windowsByApp[item.bundleIdentifier] ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            header

            Divider()

            // Window list or empty state
            if windows.isEmpty {
                emptyState
            } else {
                windowList
            }
        }
        .padding()
        .frame(maxWidth: 320)
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        HStack(spacing: 8) {
            Image(nsImage: item.icon)
                .resizable()
                .frame(width: 24, height: 24)

            Text(item.displayName)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            if !windows.isEmpty {
                Text("\(windows.count) windows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "macwindow")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No windows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
    }

    // MARK: - Window List

    @ViewBuilder
    private var windowList: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(windows) { window in
                    WindowRowView(window: window, item: item)
                }
            }
        }
        .frame(maxHeight: 300)
    }
}

// MARK: - Window Row View

struct WindowRowView: View {
    let window: WindowInfo
    let item: TaskbarItem

    @Environment(AppState.self) private var appState
    @State private var thumbnail: NSImage?
    @State private var isHovered = false
    @State private var isLoadingThumbnail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Window name
            Text(window.displayName)
                .font(.subheadline)
                .lineLimit(2)
                .truncationMode(.tail)

            // Thumbnail (if enabled and permission granted)
            if appState.settings.showWindowPreviews && appState.hasScreenRecordingPermission {
                thumbnailView
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
        )
        .onHover { isHovered = $0 }
        .onTapGesture {
            // In sandbox, we can only activate the entire app
            appState.activateApp(item)
        }
    }

    // MARK: - Thumbnail View

    @ViewBuilder
    private var thumbnailView: some View {
        if let thumb = thumbnail {
            Image(nsImage: thumb)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: appState.settings.previewSize)
                .cornerRadius(4)
                .shadow(radius: 2)
        } else if isLoadingThumbnail {
            HStack {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
                Spacer()
            }
            .frame(height: 60)
        } else {
            // Placeholder that triggers loading
            Color.clear
                .frame(height: 60)
                .task {
                    await loadThumbnail()
                }
        }
    }

    private func loadThumbnail() async {
        isLoadingThumbnail = true
        thumbnail = await appState.requestThumbnail(for: window.id)
        isLoadingThumbnail = false
    }
}

// MARK: - Preview

#Preview {
    WindowListPopover(item: TaskbarItem(
        bundleIdentifier: "com.apple.finder",
        displayName: "Finder",
        icon: NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!,
        isPinned: true,
        isRunning: true,
        windowCount: 2
    ))
    .environment(AppState())
    .frame(width: 280)
}
