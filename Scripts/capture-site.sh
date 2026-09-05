#!/bin/bash
# Render a specific released source revision; never execute the shipping app.
set -euo pipefail
cd "$(dirname "$0")/.."
revision="${1:-v0.5.0}"
capture_tmp="$(mktemp -d)"
trap 'rm -rf "$capture_tmp"' EXIT
mkdir -p "$capture_tmp/source" "$capture_tmp/cache" docs/assets/images
# Isolate the reference so current development UI cannot silently enter release media.
git archive "$revision" TaskLane | tar -x -C "$capture_tmp/source"
sources=()
while IFS= read -r source; do
  case "$source" in */TaskLaneApp.swift|*/AppDelegate.swift) continue ;; esac
  sources+=("$source")
done < <(find "$capture_tmp/source/TaskLane" -name '*.swift' -type f | sort)
swiftc -swift-version 5 -module-cache-path "$capture_tmp/cache" -o "$capture_tmp/capture" "${sources[@]}" Scripts/capture-site.swift
"$capture_tmp/capture" "$PWD/docs/assets/images"
