#!/bin/bash
set -e

# Create DMG installer

VERSION="${1:-0.1.0}"
APP_NAME="TaskLane"
DIST_DIR="dist"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"
VOLUME_NAME="$APP_NAME $VERSION"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"

echo "Creating DMG for version $VERSION..."

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: App bundle not found at $APP_BUNDLE"
    echo "Run create-app.sh first"
    exit 1
fi

# Remove existing DMG if present
rm -f "$DMG_PATH"

# Create temporary directory for DMG contents
TMP_DMG_DIR=$(mktemp -d)
cp -R "$APP_BUNDLE" "$TMP_DMG_DIR/"

# Create symbolic link to Applications folder
ln -s /Applications "$TMP_DMG_DIR/Applications"

# Create DMG
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$TMP_DMG_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Clean up
rm -rf "$TMP_DMG_DIR"

echo "DMG created at: $DMG_PATH"
echo "Size: $(du -h "$DMG_PATH" | cut -f1)"
