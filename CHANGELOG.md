# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- The presence dot in the account menu and its status submenu (Online, Away, Offline) sits in its
  ring again, centred in the icon column and on its label: the menu's icon size reached the dot's
  own drawing, which spilled out of its ring, down and to the right (as in
  [adwaita-for-sable#4](https://github.com/CR0CKER/adwaita-for-sable/issues/4)).
- A highlighted menu row keeps its presence dot's colour instead of turning it white.

## [1.0.0] - 2026-11-17

### Added

- macOS Light and macOS Dark: Slack for Mac's layout in neutral macOS grey and system blue, with
  an integrated title bar, one inset content card with concentric corners, and Slack-style drop
  shadows.
- macOS Flat Light and macOS Flat Dark: the same themes with hairlines instead of edge shadows.
- `build.sh`, which builds all four themes from `src/`, and `tools/check.sh`, the CI gate.
- Helpers in `tools/` for inspecting a running Sable over Chrome DevTools Protocol.

[Unreleased]: https://github.com/CR0CKER/sable-theme-macos/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/CR0CKER/sable-theme-macos/releases/tag/v1.0.0
