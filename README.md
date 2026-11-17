# macOS themes for Sable

Light and dark themes that make Sable look like a native Mac app, laid out like Slack for Mac. Two versions share one layout: **macOS** (Slack-style drop shadows, no hairlines) and **macOS Flat** (hairlines, no edge shadows).

- **Integrated title bar**: no title strip and no window title. In the wide layout the native traffic lights float over the top of the space rail (padded down 28px to clear them), and the room list header and content card run up to the window's top edge. Header bars and the rail top move the window. In the narrow layout a 28px band in the window colour holds the lights.
- **One window surface**: band, space rail and room list share one neutral macOS grey.
- **Inset content card**: the conversation (header, timeline, composer, side panels) sits in a white (dark: near-black) card with 10px corners, inset 4px from the window edges (top, right, bottom). Wide layout only (≥ 48rem).
- **Slack details**: rounded-square avatars and space icons, a ring around the selected space, the open room filled with system blue, a bordered composer box, full-width grey message hover.
- **macOS controls**: San Francisco at 13px, 28px controls, blue focus ring, translucent blurred menus with blue highlight, light help-tag tooltips, macOS toggles and segmented pickers, System Settings–style grouped boxes in Settings, overlay scrollbars.

## Files

| File | What it is |
|---|---|
| `macos-light.sable.css` | Importable light theme (built) |
| `macos-dark.sable.css` | Importable dark theme (built) |
| `macos-flat-light.sable.css`, `macos-flat-dark.sable.css` | Flat version (built): hairlines instead of drop shadows on the card and pane edges |
| `src/flat.css` | Overrides for the flat version, appended after `structure.css` |
| `src/tokens-light.css`, `src/tokens-dark.css` | Header and colours for each appearance |
| `src/structure.css` | All layout and component rules, shared by both |
| `build.sh` | Rebuilds all four theme files from `src/` |

Edit the files in `src/`, then run `./build.sh`. Sable links imported theme files to their path (`sable-theme-files:<account>` in Local Storage) and re-reads them every second, so a rebuild shows up in the running app without re-importing. Don't edit the built files directly.

## Install

1. Sable → Settings → Appearance → Themes: import `macos-light.sable.css` and `macos-dark.sable.css`.
2. Set the light theme to **macOS Light**, the dark theme to **macOS Dark**, and the theme to **System** so it follows macOS appearance.
3. Keep Sable's **custom title bar** setting on (`customTitleBar: true`). With it, Sable opens the window with `titleBarStyle: "hidden"` and sets `data-client-decorations="mac"`, which the title-bar rules target. With it off, you get the standard macOS title bar and everything else still applies.

## How it hooks into Sable (v26.11.1)

- Colours: the `--sable-*` tokens, same set as the Adwaita themes.
- Title bar: under `:root[data-client-decorations=mac]`, wide layout sets `--titlebar-height: 0`, hides `.titlebar` and pads `.sidebar .rail` by 28px; narrow layout keeps a 28px `.titlebar` band. The traffic lights are native, so their position can't be changed from CSS; 28px is where macOS centres them.
- Sable rewrites theme CSS on load: `body.sable-remote-theme` becomes `body.remote-theme` and `--sable-*` becomes `--*`.
- Live debugging: launch with `open -a Sable --args --remote-debugging-port=9222 --remote-address=127.0.0.1` and use Chrome DevTools Protocol. Restart normally afterwards to close the port.
- Content card: `.drawer-viewport .content-panel` inside `@media (width >= 48rem)`.
- Header bars (`.panel-header`, `.room-nav-header`, `.settings-nav-header`) are drag regions; their buttons, links and inputs are `no-drag`, and menus/dialogs are `no-drag` so popovers over a header stay clickable.
- Only semantic class names are used, never `svelte-*` hashes, so it should survive Sable updates unless the class names change.
