# Application composition (0.10)

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
category capsules filter the list. Select/deselect and select/clear shown modify
a draft; Apply calls `Option:SetValue(draft)` once. Cancel discards the draft.
Optional `Applied(draft)` runs after that existing native callback.

Optional `Action(id)` / `ActionText` can call an existing equipment action.
`Inspect` must explicitly return `ActionEnabled=true` to expose it. An optional
`Changed` signal refreshes the current details and disconnects on dismissal.
`Inspect.Text` accepts rich text: escape untrusted names. `Inspect.Image` accepts
a native icon reference or `{Image=..., ImageRectOffset=..., ImageRectSize=...}`.
Application readers that change executor thread identity must restore it before
returning to the UI. Keep inspection read-only; perform actions only in `Action`.

Dialogs accept `Width` as a preferred logical width, clamped to 75% of the main
window. Menus, notification history, dialogs and popped-out containers use solid
Cosmic material. Main window and cards retain the selected glass/opaque setting.
The footer is centered with equal safe insets; the application logo is rounded.

Runtime validation covers draft/apply/cancel, searches, recipe and equipment
inspection, narrow/wide reflow and unchanged native config roundtrips. Physical
touch devices, gamepad/screen readers, all themes and 200% text scaling still
need device testing. This is not a WCAG conformance certification.
