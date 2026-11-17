# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [1.0.2] - 2026-11-17

### Fixed

- On Linux and Windows, with Sable's own title bar, the room header and the content card start
  below that bar instead of under it (it covered the top of the header's buttons), and in the
  narrow layout the header is tall enough for its buttons. On the Mac, the narrow layout's header
  grows by the title band's height for the same reason; the wide layout is unchanged.
- On systems without the Mac fonts (Linux, Windows), sender names in the timeline show again, and
  text uses the system's UI font: the emoji font came first, and Sable's name width (`24ch`)
  collapsed to nothing.

## [1.0.1] - 2026-11-17

### Fixed

- The presence dot in the account menu and its status submenu (Online, Away, Offline) sits in its
  ring again, centred in the icon column and on its label: the menu's icon size reached the dot's
  own drawing, which spilled out of its ring, down and to the right (as in
  [adwaita-for-sable#4](https://github.com/CR0CKER/adwaita-for-sable/issues/4)).
- A highlighted menu row keeps its presence dot's colour instead of turning it white.

### Changed

- Header bar icons are one size: Sable draws Members, More options and the narrow layout's Back
  arrow at 24px, beside 18px neighbours; all are 18px now.

## [1.0.0] - 2026-11-17

### Added

- macOS Light and macOS Dark: Slack for Mac's layout in neutral macOS grey and system blue, with
  an integrated title bar, one inset content card with concentric corners, and Slack-style drop
  shadows.
- macOS Flat Light and macOS Flat Dark: the same themes with hairlines instead of edge shadows.
- `build.sh`, which builds all four themes from `src/`, and `tools/check.sh`, the CI gate.
- Helpers in `tools/` for inspecting a running Sable over Chrome DevTools Protocol.

[1.0.2]: https://github.com/CR0CKER/sable-theme-macos/releases/tag/v1.0.2
[1.0.1]: https://github.com/CR0CKER/sable-theme-macos/releases/tag/v1.0.1
[1.0.0]: https://github.com/CR0CKER/sable-theme-macos/releases/tag/v1.0.0
