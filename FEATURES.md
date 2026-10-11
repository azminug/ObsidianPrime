# ObsidianPrime 0.6 capability coverage

The workbench uses the native Ultra constructors and managers. Its material layer changes presentation; it does not replace their storage, callbacks, selection models, or popup implementations.

| Family | Where to exercise it |
| --- | --- |
| Toggle, checkbox, input, numeric input, standard/compact slider | Components → Inputs |
| Buttons, sub-buttons, double-click, disabled state, tooltips | Components → Inputs |
| KeyPicker, press key, synchronized toggle key, keybind menu | Components → Inputs |
| ColorPicker, transparency, copy/paste color | Switch color swatch in Components → Inputs |
| Single/multi/dictionary/searchable/live Player/Team dropdown | Components → Choices |
| Expanded dropdown and ordered PriorityDropdown | Components → Choices |
| DependencyBox and DependencyGroupbox | Components → Inputs → Show dependent controls |
| Native sidebar sub-tabs | Components → Inputs / Choices |
| Groupbox collapse/pop-out, tabboxes, nested tabbox, warning banner | Layouts |
| Image, interactive Viewport, native UI passthrough | Media |
| PlayerInfo and Discord/community card | Media |
| VideoFrame controls | Media → Video; provide a permitted Roblox video asset |
| Typed/action/progress notifications and history/copy/clear | Feedback |
| Dialog, delayed action, dismiss behavior | Feedback → Open dialog |
| Loading, sidebar controls, progress/error/retry | Feedback → Loading / error preview |
| Unsupported screen and localization | Feedback; isolated library instance with a return action |
| StatusLabel countdown and StatGrid | Feedback and Overview/Fishing |
| Draggable label/button/image button and watermark | Feedback → Floating widgets |
| Native minimized subtitle and labels | Feedback → Test minimized labels |
| Key access UI | Key access; local test key `IMPERIUM` |
| ThemeManager, theme colors/font/background, JSON/custom theme tools | Profiles |
| SaveManager save/load/delete, JSON/share tools, load reports, reset, autosave/autoload settings | Profiles |
| Window minimize, resize, positioning, snapping, compact sidebar, DPI, glow, cursor, rich footer | Settings and Layouts |
| Search | Native window search field |

All 21 `Funcs:Add…` element constructors have a workbench example. The structural baseline guard retains all 610 distinct named function entries in Library.lua, 81 in SaveManager, and 45 in ThemeManager. This inventory includes internal helpers; it is not a claim of 610 public APIs or proof of behavior for every method.

## Compatibility contract

- Groupbox collapse and pop-out retain Ultra's enabled defaults. Individual application groups may explicitly opt out; the Fishing page does so for its compact layout.
- `GroupFade` is opt-in. Existing CreateWindow callers keep their original root class.
- `Materials.new(Library)` installs theme-aware surfaces for existing and future components. Lazy notification history, context menus, dialogs, expanded menus, loading screens, and pop-outs receive the same treatment. Color swatches and media retain their content colors.
- `Cosmic.new` retains the minimize controller and forwards native minimized-label handles into the capsule details area. `SetText`, `SetVisible`, `Destroy`, and `ClearMinimizedLabels` remain usable.
- SaveManager is unchanged from the pinned baseline. Preview profiles use `ObsidianPrime/PreviewProfiles/Workbench`, separate from production settings. No autoload profile is automatically applied at preview startup; a manual action is available.
- No gameplay remotes or gameplay automation are attached to these component demonstrations.

## Validation record

On 2026-10-10, Potassium PID 13276 ran the actual 0.4 bundle. Luau `-O0` compilation, baseline function inventory, addon lifecycle tests, spring numerical tests, and selected material contrast checks pass.

Live checks passed for JSON roundtrip (slider, checkbox, multi-select, priority, keybind), file save/load/delete in the isolated preview folder, dependency toggling, group collapse and pop-out, tabbox pop-out, dropdown/priority expansion, native dialog, loading progress/error, material theme changes, opaque/glass switching, native minimized-label visibility/state, and isolated unsupported-screen cleanup. Notification history and color picker were also visually inspected in Roblox.

`tests/workbench-smoke.lua` repeats the core runtime checks after the preview is loaded. It restores the saved UI configuration; it does not invoke gameplay, clipboard, kick, or destructive reset actions.

## Remaining validation boundaries

0.6 adds a shared component system (DESIGN-SYSTEM.md) and `tests/component-system-smoke.lua`. It preserves native addon handles while giving switch/checkbox labels a separate addon rail, and keeps an explicit unlock for native custom-radius behavior. Sidebar selection is clipped between the header and footer; dropdown values keep full strings and use width-based ellipsis. Workbench, motion, and component tests run on PID 26184.

The 0.5 preview was executed through Potassium on PID 26184 on 2026-10-11. The core workbench smoke was repeated. `tests/glass-motion-smoke.lua` adds live checks for invisible window dividers, one-pixel rims, soft shadows, vertical tab entry, rapid tab/tabbox/collapse/minimize reversals, stable subtab text scale, and reduced motion. The tabbox retains its native ScrollingFrame inside an opt-in CanvasGroup; destroying the tab also removes this wrapper. Explicit left/right `TabSwipeFrom` options remain supported; the Imperium default is bottom.

Video playback requires an accessible asset and was not certified by constructing a blank VideoFrame. Mobile/touch, other executors, large-DPI reflow, assistive technology, clipboard operations, all notification/popup keyboard paths, autosave/autoload across restarts, and destructive reset/kick flows still need dedicated acceptance testing. Material/token checks do not constitute WCAG AA conformance. Whole-game FPS is not an isolated library benchmark. This is a complete feature workbench for hardening the fork, not a blanket production-readiness certification.

## Navigation architecture 0.7

Flat sidebar and one adaptive upper capsule are the defaults. All 610 named Library entries, 81 SaveManager entries, 45 ThemeManager entries, and 21 preview constructors remain present. Legacy sidebar subcategories and decorative underlines can be opted into explicitly. Live navigation regression passed on PID 26184: default font availability, header centerline, `99+` badge, long sidebar names at two widths, 12-category overflow and auto-reveal, removal/alignment reflow, pop-out scroll inset, and the shared left alignment axis. Component, workbench, and motion tests passed after updating the scrollbar test to create actual overflow in the now-shorter flat sidebar. Exact SF Pro Text is not bundled; a compatible font-family asset is required.

## Shell refinement 0.8

Builder Sans is now explicitly agreed as the default. Continuous sidebar glass, centered logo/menu glyphs, a bounded search shell, leading subcategory placement, half-height capsule radii, and full-body hover decoration are covered by `tests/shell-polish-smoke.lua`. PID 26184 passed navigation, component, workbench and motion regression checks; hover extents also passed across the feature workbench. Drag from the right outer edge was verified with native pointer input in the 0.7 architecture, retained unchanged in 0.8. Remaining accessibility limits are listed in ACCESSIBILITY.md.

## Capsule and card spacing 0.9

Live validation on PID 26184 passed: search outline clearance, 16px header bottom spacing, capsule end gutters including auto-reveal of first/last categories, consistent tabbox field insets through tab switches, native component geometry, config JSON roundtrip, pop-out/collapse, notification/dialog materials, rapid motion reversal and reduced motion. The 610/81/45 baseline API inventory and all 21 workbench constructors remain present. Syntax compilation and addon lifecycle/motion checks passed. Pointer, touch and accessibility limits from prior sections still apply.
