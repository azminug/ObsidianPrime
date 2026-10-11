# ObsidianPrime — Imperium UI

Local development copy of ObsidianUltra for the Imperium script UI.

- Source: https://github.com/joustingmatch/ObsidianUltra
- Baseline commit: `92b2f6c90e78d47cab449bdfc2d558d7c35a503c`
- Baseline commit date: 2026-09-26
- Copied on: 2026-10-10
- Local branch: `imperium-ui`
- Baseline tag: `obsidian-ultra-baseline`
- Source remote: `upstream`
- Fork: https://github.com/azminug/ObsidianPrime
- Fork remote: `origin`

The baseline tag preserves the original source. LICENSE and attribution are retained.
Version 0.14 is published on `main` and the integration tag `imperium-v0.14.0`.
Use the tag for application integrations; `imperium-ui` retains the development branch.

## Development files

- `Library.lua`: library implementation and visual components.
- `Library.d.luau`: API types.
- `addons/ThemeManager.lua`: themes.
- `addons/SaveManager.lua`: config persistence.
- `assets/`: bundled assets.

Compare changes with `git diff obsidian-ultra-baseline`.

## Loading caveat

`Example.lua` downloads the library and addons from ObsidianPrime on GitHub.
Running that example will not load unpublished local edits.
The sibling `../obsidian-ultra-demo.lua` also loads a pinned remote Ultra version.
Use `ImperiumDemo.lua` to load edits from the executor's `ObsidianPrime/` folder.

Bundled asset URLs point to ObsidianPrime; the external Lucide dependency remains.
This copy is a development baseline, not an offline/self-contained distribution.

## Frosted modules

`addons/Motion.lua` provides cancellable damped springs. `addons/Cosmic.lua` installs material, capsule, focus, and lifecycle behavior. `addons/Acrylic.lua` owns camera-local blur/glass effects. `GroupFade = true` opts the window into a CanvasGroup for whole-window fades; existing callers retain the original root class unless they request it.

`tools/build-preview.py` creates the ignored standalone source bundle for Potassium. The latest 0.14 preview targets the explicitly selected PID 26184; the earlier 0.4 preview used PID 13276. The same library and addons are available in the integration tag.

## Complete workbench (0.4)

Materials.lua is the shared skin for native/lazy surfaces and keeps ThemeManager registry behavior. Showcase.lua exercises all native element constructor families and installs unmodified SaveManager in a preview-only folder. See FEATURES.md for parity inventory and runtime coverage. Collapse/pop-out defaults are restored; native minimized labels are rendered below the capsule when minimized.

## Glass and motion refinement (0.5)

Window divider visuals are transparent while their resize hit targets remain intact. Shared group materials use one-pixel gradient rims, subtle concentric shadow strokes, and static directional shading. Button and subtab feedback no longer scales text. Tabs and tabboxes use cancellable vertical spring/fade transitions; group collapse settles its clipping state from the spring completion rather than a fixed timer. Generation checks prevent stale callbacks from hiding newly reopened content. Reduced motion snaps to the same final states.
