# Development notes

How Sable's theming works, why the theme looks the way it does, and how to work on it. The
[README](../README.md) is the user-facing summary.

## Contents

- [Sources and build](#sources-and-build)
- [The dev loop](#the-dev-loop)
- [Debugging the live app](#debugging-the-live-app)
- [How Sable themes work](#how-sable-themes-work)
- [Design decisions](#design-decisions)
- [Releasing](#releasing)
- [Not yet reviewed](#not-yet-reviewed)

## Sources and build

Four themes come from one set of sources:

| Built file | Name in Sable | What it is |
|---|---|---|
| `macos-light.sable.css` | macOS Light | Shadow version, light |
| `macos-dark.sable.css` | macOS Dark | Shadow version, dark |
| `macos-flat-light.sable.css` | macOS Flat Light | Flat version (hairlines instead of shadows), light |
| `macos-flat-dark.sable.css` | macOS Flat Dark | Flat version, dark |

- `src/tokens-light.css`, `src/tokens-dark.css`: the `@sable-theme` header plus all colours, as
  Sable's `--sable-*` tokens and the theme's own `--mac-*` tokens.
- `src/structure.css`: every layout and component rule, shared by all four themes. It uses only
  `--mac-*` and Sable tokens, never literal colours, except where it needs one (white menu text,
  switch thumbs).
- `src/flat.css`: overrides appended last for the flat version (hairline card and pane edges,
  popovers with hairline plus shadow).

`build.sh` concatenates them: `tokens + structure` for the shadow version, and
`tokens (id, name, description and tags rewritten with sed) + structure + flat` for the flat
version. **Edit `src/`, then run `./build.sh`. Never edit the built files.** They are committed so
people can download them straight from the repo.

`tools/check.sh` is the one gate, run by CI on every push and pull request. Run it before committing:
it rebuilds, fails if the built files differ from what's committed, checks each theme's header,
and refuses selectors that use Sable's `svelte-*` hashes.

<sub>[↑ Back to contents](#contents)</sub>

## The dev loop

Sable links a theme imported from a file to that file's path (Local Storage key
`sable-theme-files:<account>`) and re-reads linked files every second (a `setInterval` in the
renderer, IPC `sable-read-theme-file`). Import the four built files once, and from then on
`./build.sh` reaches the running app within about a second, with no re-import.

If a theme stops updating, it was imported in a way that stored a copy instead of a link. Remove
it and import it from the file again.

Don't write theme data into Sable's Local Storage or synced settings by hand. Theme settings are
synced to the Matrix account (`sable-sync-base:<account>:moe.sable.next.settings`), and editing them
behind the app risks a sync conflict. Import and select themes through Sable's own UI (Settings →
Appearance → Themes).

<sub>[↑ Back to contents](#contents)</sub>

## Debugging the live app

Sable accepts Chromium's remote debugging switch (its Electron fuses disable Node's `--inspect` and
`RUN_AS_NODE`, not this). On macOS:

```sh
osascript -e 'quit app "Sable"'
open -a Sable --args --remote-debugging-port=9222 --remote-address=127.0.0.1
curl -s http://127.0.0.1:9222/json/list   # the page target is sable-app://app/
```

**While the port is open, any local process can drive your logged-in Matrix session.** Close it
when you're done by quitting Sable and opening it normally.

Helpers in `tools/` (no dependencies; Node 20 needs `--experimental-websocket`):

- `node --experimental-websocket tools/cdp.mjs eval file.js`: evaluates a JS expression file in the
  page and prints the result (return a string or JSON).
- `node --experimental-websocket tools/cdp.mjs shot out.png`: screenshot of the page at 2x device
  pixels. It does **not** include the native traffic lights.
- `tools/live.sh [out.png]`: rebuild, wait for Sable's reload, take an optional screenshot.
- `python3 -I tools/px.py out.png <y> <x0> <x1>`: prints pixel colours along a row. Use it to check
  that shadows or hairlines are really drawn; they're too subtle to judge from a downscaled
  screenshot.

To preview CSS without changing files, append a `<style id="mac-live">` to `<body>` and remove it
afterwards. Write it the way Sable rewrites themes (see below). Don't edit `#sable-custom-theme`:
Sable re-renders it from its store and overwrites the change.

<sub>[↑ Back to contents](#contents)</sub>

## How Sable themes work

Learned by reading the app (Sable v26.11.1 for macOS).

- **Format:** a CSS file whose leading comment holds `@sable-theme`, `id`, `name`, `author`,
  `description`, `kind: light|dark`, `contrast` and `tags`. Rules target
  `body.sable-remote-theme`, and tokens are written as `--sable-*`.
- **Load-time rewrite:** Sable replaces `body.sable-remote-theme` with `body.remote-theme` and
  `--sable-X` with `--X`, then puts the CSS in `<style id="sable-custom-theme">`. CSS injected over
  CDP must use the rewritten form.
- **App CSS for reference:** `/Applications/Sable.app/Contents/Resources/dist/_app/immutable/assets/*.css`,
  JS in `.../immutable/{nodes,chunks}/*.js`, and the Electron main process in
  `Resources/app.asar` (grep it as text). Theme selectors must use **semantic class names only**,
  never the `svelte-xxxx` hashes, which change between builds.
- **Title bar on macOS:** with Sable's custom title bar setting on (`customTitleBar: true` in
  `~/Library/Application Support/moe.sable.client.electron/settings.json`), the window opens with
  `titleBarStyle: "hidden"`. The native traffic lights stay at macOS's default spot (about 7–68px
  from the left, centred in the top 28px) and **can't be moved from CSS**. The renderer sets
  `<html data-client-decorations="mac">` and draws `.titlebar.titlebar-mac > .drag > .title`
  (default height `--titlebar-height: 2rem`, included in `--safe-top`).
- **Title bar elsewhere** (Linux, Windows): with Sable's own title bar the renderer sets
  `data-client-decorations="desktop"` and draws a 32px `.titlebar` with minimise, maximise and
  close. The theme's title-band rules are `mac`-only, so that strip stays, and everything that
  reaches the window's top must clear it: the card's top offset is `--safe-top` plus `--mac-gap`
  (`--safe-top` is 0 in the Mac's wide layout, so the Mac is unchanged), and the header bar adds
  Sable's `--edge-inset-top` to its height, as Sable's own rule does (in the narrow layout the
  header reaches under the band and pads itself down). To check, set
  `document.documentElement.dataset.clientDecorations` to `mac` or `desktop` on any machine and
  measure: the Mac's layout follows (the native traffic lights don't).
- **Fonts elsewhere:** none of the Mac fonts exist on Linux or Windows, so `system-ui` follows them
  in `--font-family-base`, ahead of the emoji font. Without it the emoji font came first; its "0"
  is 0px wide, so every `ch` width collapsed (Sable caps sender names at `24ch`: names vanished).
- **Wide layout** (Sable's breakpoint, `width >= 48rem`): `.sidebar` is `position: fixed`
  (z-index 2) and holds `.desktop-navigation` → `.desktop-navigation-main` (`.rail` +
  `.room-nav`) and `.desktop-tools` (the bottom bar: account button and quick tools). The
  conversation is `.drawer-viewport > .drawer-track > .content-panel` (a flex child with
  `flex-basis`, `width` and `height` at 100% and top padding `--safe-top`), which holds `.room-view`
  with `.panel-header`. `.drawer-viewport` **clips** its overflow, so nothing drawn left of
  `.content-panel` shows.
- **Variables:** `--navigation-rail-width` is set on `:root` (4.125rem by default) and can be
  overridden on `body`. `--room-nav-width` is set inline on `.app-shell` and `.room-nav`
  (user-resizable, stored as `sable-room-navigation-width`), so it is **not** available on `body`
  or `.titlebar`.
- **The canvas trick:** `body`'s background (`--bg-container`) paints the canvas, so a
  `body::before` with `position: fixed; z-index: -1` lies above the page colour and below all
  content. The theme draws the Slack-style card this way, behind two separate containers.
- **Space banners:** `.room-nav-top > .room-banner` (the image), with `.room-nav-header.on-banner`
  laid absolutely over it (Sable gives it a dark scrim and white text).
- **Space lobby:** the room directory is `.content-panel .category`.

<sub>[↑ Back to contents](#contents)</sub>

## Design decisions

These are settled. Change them on purpose, not by accident.

1. **The model is Slack for Mac**, in neutral macOS grey and system blue (not Slack's aubergine),
   as a light and dark pair.
2. **Integrated title bar, no window title.** In the wide layout the title band is removed
   (`--titlebar-height: 0`, `.titlebar` hidden). The traffic lights float over the top of the space
   rail, which is padded down 28px (`--mac-band`) and widened to 80px so the lights don't overlap
   the card's edge. The rail top and header bars are `-webkit-app-region: drag`; their controls are
   `no-drag`. The narrow layout keeps a 28px band.
3. **One card** (room list plus conversation, as in Slack), inset 4px (`--mac-gap`) from the
   window's top (below Sable's title bar where it draws one), right and bottom; only the rail stays on the window grey. `body::before` draws the
   card; `.room-nav`, `.rail` and `.desktop-tools` are transparent over it, and `.content-panel`
   paints the conversation over the card's light tint (`--mac-list-bg`, Slack's slightly grey
   channel list).
4. **Concentric corners:** the card's radius is `--mac-window-radius` (16px, an assumed macOS 26
   value, not measured) minus the gap, so 12px. If corners look off, change only
   `--mac-window-radius`.
5. **Slack-style shadows, no hairlines** (shadow version): the card casts `--mac-card-edge` onto
   the rail. The conversation pane's shade on the room list is drawn by `.sidebar::after` at the
   sidebar's right edge, because the pane itself is clipped. Hairlines were removed wherever a
   shadow exists. Push buttons keep their outline, and lines without shadows (the header's bottom
   line, row separators, grouped boxes) stay.
6. **Flat version:** the same theme with hairlines instead of those shadows.
7. **Alignment** was fixed against the live DOM: the room-list title and conversation title share a
   centre line (both headers start at `--mac-gap`), the room-list title starts at the section
   labels' x, and the account avatar is centred in the 80px rail.
8. **Space banners** start at the card's top edge with the card's corner, and the title inherits
   its colour (white on banners).
9. **Header bars are 64px** (`--header-height`), up from 48 and then 56: room headers with a
   description (`.room-title` plus `.room-topic` beside the 36px avatar) looked crammed. The title
   has `line-height: 20px`, the topic `margin-top: 4px; line-height: 1.35`. The room-list header
   shares the variable, so both headers stay the same height. In the narrow layout the header also
   reaches under the title band and pads itself down by `--edge-inset-top`, so its height is
   `--header-height` plus that inset, as in Sable's own rule (64px alone left its 44px buttons
   overlapping the band by about 4px; 1.0.2).
10. **The pinned-messages count** (`.panel-header-button .pin-badge`) sits at the icon's top-right
    corner instead of over the pin glyph: a solid pill with a cut-out ring in the header colour.
11. **Icons:** 18px (`--mac-icon-size`) in the header bars, sidebar and composer, 16px in menus.
    Every header bar icon is 18px: Sable draws Members, More options and Back at 24px
    (`.members-button svg` and so on, `--icon-size-medium`), so the theme sizes
    `.panel-header-button svg` itself (1.0.1). Menus size only a row's own icon,
    `.menu-item > svg` as Sable does: a descendant selector also stretched the presence dot's
    inner svg (a 10px ring) out of its ring, and the account menu's dot is re-centred on the 16px
    icon column (Sable centres it on 20px). A highlighted menu row turns its text and icons white,
    but not a presence dot, which keeps its status colour (1.0.1). Check icons with Adwaita for
    Sable's [`scripts/icon-probe.mjs`](https://github.com/CR0CKER/adwaita-for-sable/blob/main/scripts/icon-probe.mjs),
    which compares the current screen with stock Sable and works with any theme.
12. **Made for macOS.** On Linux and Windows the themes only have to stay usable: Sable's own
    title bar (minimise, maximise, close) stays above the card, the card and headers clear it, and
    `system-ui` stands in for the Mac fonts (1.0.2). An integrated title bar there (Sable's window
    buttons restyled as traffic lights) was started and dropped on purpose (2026-11-17).

Other choices: SF Pro at 13px, 28px controls, the open room filled with system blue and white text
(Slack's active-channel treatment), rounded-square avatars, translucent blurred menus with a blue
highlight, System Settings–style grouped boxes in Settings, overlay scrollbars (the technique comes
from [Adwaita for Sable](https://github.com/CR0CKER/adwaita-for-sable)), and hairline text fields.
Sable draws field edges as inset box-shadows, so those are overridden with `box-shadow`, not border
variables.

<sub>[↑ Back to contents](#contents)</sub>

## Releasing

1. Bump `v1.x.y` at the end of the `description:` line in both `src/tokens-*.css`, run
   `./build.sh` and `tools/check.sh`.
2. Add a section to `CHANGELOG.md` and commit everything together.
3. Tag and publish the four built files as release assets, so the README's
   `releases/latest/download/` links keep working:

   ```sh
   git tag -a v1.x.y -m v1.x.y && git push origin v1.x.y
   gh release create v1.x.y --title v1.x.y --notes-file <changelog section> *.sable.css
   ```

<sub>[↑ Back to contents](#contents)</sub>

## Not yet reviewed

- The dark themes have had only a quick check in the live app.
- The traffic lights were never seen in a screenshot (CDP doesn't capture them). The rail width
  (80px) and padding (28px) are based on macOS defaults.
- The 16px window corner radius is an assumption.
- Dialogs other than Settings, the image viewer, the threads and members side panels, the narrow
  (< 48rem) layout, and the composer's expanded mode.
- 1.0.2's taller narrow-layout header (92px: the 28px band plus 64px) was measured with
  `data-client-decorations="mac"` set on another system, not seen on a Mac with its traffic
  lights. The wide layout measured identical before and after.

<sub>[↑ Back to contents](#contents)</sub>
