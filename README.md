# macOS themes for Sable

[![check](https://github.com/CR0CKER/sable-theme-macos/actions/workflows/check.yml/badge.svg)](https://github.com/CR0CKER/sable-theme-macos/actions/workflows/check.yml)
[![Latest release](https://img.shields.io/github/v/release/CR0CKER/sable-theme-macos)](https://github.com/CR0CKER/sable-theme-macos/releases/latest)
[![License: MIT](https://img.shields.io/github/license/CR0CKER/sable-theme-macos)](LICENSE)

Makes [Sable](https://sable.moe), the Matrix client, look like a native Mac app, laid out like
Slack for Mac: neutral macOS grey, system blue, light and dark. A sibling of
[Adwaita for Sable](https://github.com/CR0CKER/adwaita-for-sable).

There are two versions with the same layout:

- **macOS**: Slack-style drop shadows at the card and pane edges, no hairlines.
- **macOS Flat**: hairlines at those edges instead of shadows.

Built for **Sable v26.11.1 for macOS**. The layout rules target Sable's class names, which can
change between releases. It also works in Sable for Linux and Windows: there Sable's own title
bar (minimise, maximise, close) stays above the card, and the text uses the system's UI font.

## Install

1. Download the files from the [latest release](https://github.com/CR0CKER/sable-theme-macos/releases/latest)
   (the same files are in the repo's root):
   - [macos-light.sable.css](https://github.com/CR0CKER/sable-theme-macos/releases/latest/download/macos-light.sable.css) and
     [macos-dark.sable.css](https://github.com/CR0CKER/sable-theme-macos/releases/latest/download/macos-dark.sable.css), or
   - [macos-flat-light.sable.css](https://github.com/CR0CKER/sable-theme-macos/releases/latest/download/macos-flat-light.sable.css) and
     [macos-flat-dark.sable.css](https://github.com/CR0CKER/sable-theme-macos/releases/latest/download/macos-flat-dark.sable.css).
2. Sable → Settings → Appearance → Themes: import both files.
3. Pick **macOS Light** (or **macOS Flat Light**) as the light theme and **macOS Dark** (or
   **macOS Flat Dark**) as the dark theme.
4. Set the theme to **System**, so Sable follows macOS's appearance.
5. Recommended: keep Sable's custom title bar on (`customTitleBar: true` in Sable's
   `settings.json`). The theme then folds the title bar into the window, as Slack does (see
   *What changes*). With it off, macOS draws its standard title bar and everything else still
   applies.

To undo: pick Sable's default themes again and remove these.

**Updating**: Sable keeps a theme imported from a file linked to that file and re-reads it, so
replacing the downloaded files updates the theme. If it doesn't, remove the old themes and import
the new files.

## What changes

**Window**: no title strip and no window title. In the wide layout (48rem and wider) the native
traffic lights float over the top of the space rail, which is padded down 28px to clear them, and
the room list and conversation run up to the window's top edge. Header bars and the rail top move
the window. In the narrow layout a 28px band in the window colour holds the lights.

**Layout**: the space rail sits on the window's grey. The room list and the conversation share one
card (white in light mode, near-black in dark), inset 4px from the window's top, right and bottom
with 12px corners, concentric with the window's. The room list is slightly tinted, like Slack's
channel list.

**Slack details**: rounded-square avatars and space icons, a ring around the selected space, the
open room filled with system blue, a bordered composer, full-width grey message hover, 64px header
bars with the room's description under its name.

**macOS controls**: San Francisco at 13px, 28px controls, a blue focus ring, translucent blurred
menus with a blue highlight, light help-tag tooltips, macOS switches and segmented pickers, System
Settings–style grouped boxes in Settings, overlay scrollbars.

## Sharing

The theme isn't in Sable's built-in theme catalogue: Sable doesn't accept AI-assisted
contributions, and this theme was made with Claude Code.

The `.sable.css` files are the whole theme. Send them any way you like. They're CSS, so only
install themes from people you trust.

## Limitations

- The layout rules target Sable v26.11.1's class names. A Sable update can change them; the
  colours survive that, and parts of the layout may not.
- The traffic lights are native and can't be moved from CSS. The 80px rail and 28px band assume
  macOS's default position for them.
- The window corner radius (16px, which sets the card's 12px) is assumed for macOS 26, not
  measured.
- Not reviewed in detail yet: the dark themes, dialogs other than Settings, the image viewer, the
  threads and members panels, the narrow layout, and the composer's expanded mode.

## Building

```sh
./build.sh          # writes the four *.sable.css files from src/
tools/check.sh      # the CI gate: built files current, headers complete, no svelte-* hashes
```

- `src/tokens-light.css`, `src/tokens-dark.css`: each theme's header and colours.
- `src/structure.css`: the layout and component rules, shared by all four themes.
- `src/flat.css`: the flat version's overrides, appended after `structure.css`.
- `tools/`: helpers for working against a running Sable over Chrome DevTools Protocol.

Edit `src/`, never the built files. How Sable's theming works, the design decisions and the dev
loop are in [docs/development.md](docs/development.md); changes are in [CHANGELOG.md](CHANGELOG.md).

Issues and pull requests are welcome. Please run `tools/check.sh` before opening a pull request,
and include a screenshot for visual changes.

## License

[MIT](LICENSE).
