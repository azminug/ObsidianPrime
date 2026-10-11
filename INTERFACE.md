# Application composition (0.12)

Load `addons/Interface.lua` from the same pinned revision as `Library.lua`.
This addon composes native controls; it does not install gameplay workers or
replace option IDs, callbacks, SaveManager, or ThemeManager.

```lua
local Composition = fetch("addons/Interface.lua").new(Library, Window)
-- After building the application's tabs and config/theme sections:
for _, page in pairs(Library.Tabs) do Composition:Adaptive(page) end
```

`Adaptive(page)` expands a sole occupied column and stacks both columns when
the content area is narrower than 580 logical pixels. Widening restores each
card to its original side. It observes visibility and size changes, with no
per-frame layout loop. Call it again for a newly added page or subtab.
Native groupbox ownership, collapse/pop-out, scroll and destruction remain intact.

`Banner(group, image, title, subtitle)` adds an 80px horizontal profile/community
row with a rounded 56px image. Pass plain text; long names use ellipsis.

```lua
Composition:Browser({
    Id = "EquipmentPicker",
    Title = "Equipment",
    Option = Library.Options.EquipmentTargets, -- native Multi dropdown
    Ids = {"rod-a", "rod-b"},
    Names = {["rod-a"]="First rod", ["rod-b"]="Second rod"},
    Categories = {"Owned", "Locked"},
    Category = {["rod-a"]="Owned", ["rod-b"]="Locked"},
    Inspect = function(id)
        return {Text="Details for "..id, Image="rbxassetid://...", ActionEnabled=false}
    end,
})
```

Rows inspect on activation, including touch. Search and horizontally scrollable
category capsules filter the list. Double activation within 350ms or the inline
32px check toggles a draft selection. Drag from a check to paint the same selection
state across rows; swiping elsewhere retains normal scrolling. Select/clear shown
acts only on visible results. Apply calls `Option:SetValue(draft)` once. Cancel or
an outside tap discards the draft; outside dismissal is immediate.
Optional `Applied(draft)` runs after that existing native callback.

Optional `Action(id)` / `ActionText` can call an existing equipment action.
`Inspect` must explicitly return `ActionEnabled=true` to expose it. An optional
`Changed` signal refreshes the current details and disconnects on dismissal.
`Inspect.Text` accepts rich text: escape untrusted names. `Inspect.Image` accepts
a native icon reference or `{Image=..., ImageRectOffset=..., ImageRectSize=...}`.
Application readers that change executor thread identity must restore it before
returning to the UI. Keep inspection read-only; perform actions only in `Action`.

Dialogs accept `Width` as a preferred logical width, clamped to 75% of the main
window. Menus, notification history and dialogs use solid Cosmic material.
Popped-out modules retain glass and respect opaque mode. Each has a 32px corner
resize target with mouse/touch drag and arrow-key increments when selected.
`box:SetPopOutSize(width, height)` is the non-drag API; sizes are logical pixels
and clamped to the viewport. Existing width/max-body-height APIs remain intact.

Window `LogoOnly=true` is the default; the logo scales from 24 to 44px with sidebar
width (16%, clamped to 24–44px). Set `LogoOnly=false` to retain the legacy title presentation. The footer
has a 32px strip centered over the content area, excluding the sidebar, with 40px
side reserves. Text segments ellipsize proportionally when space is limited. Pass static and copyable segments
separately: `Footer={{Text="Script v1"},{Text="Discord",Copyable=true,CopyText=url}}`.
Only opt-in segments copy. Empty adaptive columns are hidden so they cannot absorb
scroll input; native automatic canvas sizing tracks stacked content.

Runtime validation covers draft/apply/cancel, searches, recipe and equipment
inspection, narrow/wide reflow and unchanged native config roundtrips. Physical
touch devices, gamepad/screen readers, all themes and 200% text scaling still
need device testing. This is not a WCAG conformance certification.

`ResponsiveSidebar=true` is the default. Window resize preserves the sidebar's
chosen width ratio, clamps expanded width to `MinSidebarWidth` and the available
content width, and keeps explicit compact mode compact. `SetSidebarWidth` establishes
a new preferred ratio. Set `ResponsiveSidebar=false` for a fixed sidebar width.
The minimum resizable window reserves space for both sidebar and content.
Subcategory rails share the tabbox 32px/26px rail/chip geometry and material tokens,
with a 16px gap before modules. Horizontal overflow remains scrollable.
