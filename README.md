# ObsidianPrime

An ObsidianUltra fork for Imperium. Based on
[joustingmatch/ObsidianUltra](https://github.com/joustingmatch/ObsidianUltra),
originally [deividcomsono/Obsidian](https://github.com/deividcomsono/Obsidian).
Original attribution and LICENSE are preserved.

## Frosted workbench 0.15

- Cosmic #23212C, Builder Sans, a window without divider lines, one-pixel specular rims, directional glass shading, and soft card shadows. The window's outer shadow remains off by default.
- Spring-driven window drag, vertical tab/tabbox fade, group collapse, switches, and scale/fade minimize and restore. Button feedback changes light without shrinking text.
- Draggable 256x38 capsule with logo, telemetry-driven heartbeat and FPS/ping. Click anywhere to open the menu; Ctrl+M toggles it. It starts above the window, away from the hotbar.
- Fishing uses a single grouped settings list, a slim slider with an exact-value entry, standard chevrons, and live client statistics alongside it. No duplicate Cast/Filters navigation and no fabricated catch log.
- Opaque mode, reduced motion, keyboard focus, position controls, and optional world blur.
- Continuous sidebar glass from logo to footer, a subtle vertical hairline, centered icon alignment, clipped search text, complete capsule curves, and full-body hover lighting.
- Flat sidebar by default, one adaptive subcategory capsule, aligned shell/header, inset card scrollbars, and drag from all four frame edges. Legacy nested navigation remains opt-in.
- Standard component geometry, typography weights, recessed subtabs, clipped sidebar selection, ellipsis, raised menus, input focus rings, and fading 3 px scrollbars. See [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) for exact tokens and behavior.
- `addons/Motion.lua` disconnects its spring update loop when idle. `addons/Acrylic.lua` owns a camera glass plane and camera-local effects and removes them on unload.

Builder Sans is the agreed default typeface. Optional project font families remain configurable through `CreateWindow({FontFamily = ...})`. See DESIGN-SYSTEM.md for configuration and compatibility options.

Roblox does not provide CSS backdrop-filter for this GUI. This build uses tinted surfaces plus a world BlurEffect while the menu is open; it blurs the entire 3D scene, including outside the panel. The game's separate HUD remains sharp. Turn the effect off in Settings. Graphics quality and other game effects can change its appearance.

## Full native feature workbench

The preview now includes Components, Layouts, Media, Feedback, Key access, and Profiles alongside the Imperium pages. It exercises every native element constructor, including advanced dropdowns, dependencies, pop-outs, key/color pickers, dialogs/loading, floating widgets, and the original ThemeManager/SaveManager tools. Collapse/pop-out defaults are restored. Minimized-label APIs remain visible through capsule details.

`addons/Materials.lua` applies shared, theme-aware glass to existing and lazily created controls, with solid Cosmic backplates for notification history, context menus and dialogs. Floating modules retain glass and add corner resize. `addons/Showcase.lua` organizes the native examples. [FEATURES.md](FEATURES.md) maps capabilities and records actual test coverage.

## Try local edits

Copy `Library.lua`, `ImperiumDemo.lua`, `addons/`, and `assets/` into a folder named
`ObsidianPrime` inside your executor's workspace. Then execute:

```lua
loadstring(readfile("ObsidianPrime/ImperiumDemo.lua"))()
```

For a single pasteable build, run `python tools/build-preview.py`, then execute the generated `ImperiumPreview.bundle.lua`. This bundles Lua sources; library icons/assets still use their upstream network loaders.

Alternatively paste the entire demo into the executor after copying its dependencies.
Local mode reports missing files instead of falling back to older remote code.
Press U to show/hide; Settings includes Unload. Re-executing removes only this
demo's prior instance.

`Example.lua` points at `azminug/ObsidianPrime/main`. For application integration, pin the library and every addon to the same tag or commit.

## Use the skin in a project

Keep calling the native Library/Window/group methods. `Showcase.lua` is the optional workbench and is not required by an application. Use the tagged build below so later edits to `main` do not change an existing UI:

```lua
local repo = "https://raw.githubusercontent.com/azminug/ObsidianPrime/imperium-v0.15.0/"
local function loadModule(path)
    local source = game:HttpGet(repo .. path)
    return assert(loadstring(source, "@ObsidianPrime/" .. path))()
end
local Library = loadModule("Library.lua")
local Motion = loadModule("addons/Motion.lua")
local Cosmic = loadModule("addons/Cosmic.lua")
local Materials = loadModule("addons/Materials.lua")
local Acrylic = loadModule("addons/Acrylic.lua")
Library.PrimeMotion = Motion.new()
Library:OnUnload(function() Library.PrimeMotion:Destroy() end)
local Window = Library:CreateWindow({
    Title="IMPERIUM", GroupFade=true, ToggleKeybind=Enum.KeyCode.U,
})
local Appearance = Cosmic.new(Library, Window)
local Material = Materials.new(Library)
Appearance.Acrylic = Acrylic.new(Library, Window)
-- Construct the application's native tabs and controls here.
Appearance:FinishBuild()
```

When re-executing your application, unload its previous Library instance first. Handle startup failures by calling `Library:Unload()` before reporting the error. Material hooks style controls and popups created later as well. Keep stable option IDs and your existing SaveManager folder when migrating production; the preview folder is only for the workbench.

## Scope and validation

This preview changes visual defaults and adds composition helpers. It does not
migrate the production Imperium script or alter SaveManager behavior. The workbench exposes native profiles in an isolated preview folder. Existing Ultra reset/load semantics still apply to applications
that use SaveManager.

Compact layout is selected at startup; resizing does not rebuild tabs automatically.
Reduced motion disables exposed window animation flags; some existing hover and
tooltip effects retain their own transitions. Glow remains independently optional.
FPS tests measure the whole game, not isolated library overhead.

Validation: Luau `-O0` compilation, addon lifecycle mocks, actual spring numerical tests, and material contrast calculations. Live preview was executed through Potassium on PID 13276 on 2026-10-10: native sidebar activation and capsule drag, plus runtime checks for minimize/restore, rapid reversal, reduced motion, opaque mode, and slider values. Observed whole-game FPS was around 57–60 during the session; this is not an isolated UI overhead benchmark.

Run `lua tests/imperium.test.lua`, `lua tests/cosmic.test.lua`, `python tests/motion.test.py`, `python tests/contrast.py`, and `python tests/api-parity.py`. Execute `tests/workbench-smoke.lua` only after loading the preview to repeat the runtime checks. The spring test requires the local Luau CLI described in that file.

The 0.9 preview is tested on Potassium PID 26184. `tests/glass-motion-smoke.lua` covers reversal/reduced motion and `tests/component-system-smoke.lua` covers current geometry, typography, popup opacity, focus rings, clipping, and scroll fading. Earlier validation records above describe the earlier builds, not an isolated performance benchmark.

WCAG 2.2 AA remains the target. [ACCESSIBILITY.md](ACCESSIBILITY.md) records coverage and unresolved audits; no conformance is claimed.

Upstream API documentation: https://docs.mspaint.cc/obsidian
Fork provenance and baseline: [IMPERIUM.md](IMPERIUM.md).

## Application composition 0.15

See [INTERFACE.md](INTERFACE.md) for adaptive columns, horizontal banners, and a searchable item/detail browser that keeps native option persistence. Popup surfaces are solid Cosmic; window glass remains configurable. Footer information is centered.
