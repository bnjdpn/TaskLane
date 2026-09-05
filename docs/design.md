# TaskLane website redesign and media

The site remains a static GitHub Pages site under `docs/`. Its source is now
`Scripts/site-content.mjs` plus `Scripts/build-site.mjs`; generated outputs are
`docs/index.html`, `docs/fr/index.html` and `docs/sitemap.xml`. Existing asset URLs
remain present. No native application feature was changed.

The old English/French language toggle populated initially empty elements with
JavaScript and stored a preference in localStorage. Both languages now have
complete HTML, distinct canonical URLs, reciprocal hreflang and navigable language
links. Root English is preserved and `/TaskLane/fr/` is added. Features,
installation, permission explanations, FAQ, privacy information and GitHub support
are present in both languages. There was no support form to preserve.

Visual direction: pale paper and dark slate, restrained blue actions, a large
editorial title and an actual native taskbar. Product screenshots are labelled as
native view renders with demo apps; these are not personal desktop captures.

## Evidence on 5 September 2026

GitHub's public latest-release endpoint returned `v0.5.0`, published 5 February
2026, non-draft and not a prerelease, with DMG and ZIP assets. The download CTA
points to the exact verified release page, not a guessed asset or future release.

The ZIP was downloaded for read-only inspection, without launching the app.
`vtool -show-build` on its executable reported `minos 15.0`. Its Info.plist
incorrectly advertises a minimum of 14.0 and an internal version of 1.0.0. The tag's
`Package.swift` also sets `.macOS(.v15)`. Consequently the website states macOS 15
and explains why older release notes say 14. The app's bundle metadata and release
notes have not been modified by this web task; that mismatch is a separate native
release concern. The website retains the published non-notarization warning.

The existing `screenshot.png` and `screenshot-light.png` were schematic drawings,
not app captures. They remain at their old URLs but are no longer used or labelled
as screenshots by the website. The new media use the actual `TaskbarView` at the
released `v0.5.0` source revision, rather than the later development version.

## Native capture workflow

Run on a Mac with Xcode installed:

```sh
Scripts/capture-site.sh v0.5.0
```

The script exports the requested Git revision to a temporary directory, compiles
its real views with `Scripts/capture-site.swift` and renders the native view using
SwiftUI ImageRenderer. It does not call `AppState.start`, start app/window
monitoring, request permissions, capture the desktop, or read/write user settings.
A memory-only settings store and five standard demonstration app identities are
injected. App icons come from the local macOS installation, so their appearance
can differ between macOS versions. Blur and the live clock are disabled through
existing settings for reproducible content. The native code is not patched.

The completed run rendered `docs/assets/images/taskbar-dark.png` and
`taskbar-light.png` at 1920×112. Both were inspected visually. The first attempted
compile in the restricted shell failed because Swift macro plugins could not
start; the subsequent authorized compilation and rendering completed successfully.
This proves the displayed native view, not runtime window-management behavior.

`Scripts/og-card.html` is the source for the 1200×630 share image, rendered to the
existing `docs/assets/images/og-image.png` URL.

## Validation

```sh
node Scripts/build-site.mjs
node Scripts/build-site.mjs --check
node Scripts/check-site.mjs
```

The checks cover both languages, five FAQ entries, release/notarization and
compatibility caveats, canonical and language metadata, native image references,
image dimensions, local links, anchors and sitemap routes. They do not substitute
for visual or release-content review.

Chrome comparison covered the public page before the redesign and the new EN
desktop, FR mobile 390×844 and FR tablet 768×1024. A mobile overflow caused by the
image container's grid minimum width was found and fixed. Rereading confirmed
`scrollWidth == clientWidth` at both 390 and 768. No broken images or console
errors/warnings were observed. French navigation, installation, the compatibility
FAQ disclosure and the keyboard skip link were exercised; the latter focuses
`main`. Support links were inspected without opening an issue or sending a message.

No push, deployment, app installation, permission grant or store submission was
performed.
