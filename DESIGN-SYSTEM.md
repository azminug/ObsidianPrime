# Imperium component system — 0.9

Logical pixel measurements scale with the window's DPI. The shared Materials layer applies these rules to native controls and lazily created menus; data and callbacks remain native Ultra behavior.

| Element | Rule |
| --- | --- |
| Window / card / control / capsule | Radius 16 / 12 / 8 / 999 |
| Card rim | 1 px; white vertical reflection, 28% top opacity → 9% bottom |
| Recessed navigation | One capsule behind the subtab group; inset active segment |
| Title / label / parameter | SemiBold / Medium / Regular; theme font family retained |
| Parameter color | Font color blended 13% toward the accent; lavender gray in Cosmic |
| Field rows | 14 px label + 8 px gap + 32 px field |
| Slider | 6 px label-to-hit-region gap; 28 px hit height; 4 px track; 14 px thumb |
| Toggle | Explicit 2 px inner travel inset on both states |
| Header | 32 px control height; 8 px between icon targets; centered vertically |
| Expand icon | 14 px glyph within a 28 px target |
| Collapse/sidebar chevron | 16 px glyph within a 28 px target; animated rotation |
| Popup menu | 92% material opacity, 12 percentage points above the previous 80% |
| Hover | White specular glow peaks at 7%, press at 8%; critically damped |
| Focus | 1 px accent ring on editable text inputs |
| Scrollbar | 3 px overlay; reveal on movement/entry, fade after 850 ms idle |
| Dividers | 1 px hairlines, fading at both ends |
| Overflow | Button/feature/value ellipsis; labels reserve separate addon space |

The sidebar selection is inside a noninteractive clipping viewport matching the native sidebar. Its spring can move outside this rectangle but cannot paint over the logo or bottom bar. It tracks scrolling, resizing, and active-tab changes.

Dropdown display callbacks keep the value centered at half the field height. Value images, text, the expand target, and the chevron have separate space. Ellipsis uses available width rather than a fixed character count, and the underlying value remains complete.

Radius hierarchy is locked by default. Settings → Native window options → Use Imperium radius hierarchy can be turned off to exercise the original custom-radius API. `Library.PrimeMaterial:SetRadiusHierarchy(false)` provides the same explicit override for applications. Font family changes through ThemeManager preserve the three weights.

Scroll/focus effects use event-driven springs and cancellable idle timers. Owned handlers and pending timers are removed on unload. No additional perpetual cosmetic render loop is introduced.

Run `tests/component-system-smoke.lua` on the loaded preview for runtime geometry, typography, clipping, focus, popup, and scrollbar assertions. Also run the feature and motion smoke scripts. These checks do not constitute WCAG AA certification; see ACCESSIBILITY.md for remaining platform and accessibility audits.

## Reusable navigation and shell defaults (0.7)

`CreateWindow` now defaults to a flat sidebar. `Tab:AddSubTab` still creates the full native content and APIs, but its only default controller is the upper recessed capsule. Chips share one bounded horizontal viewport, narrow to available space, truncate long names, and allow horizontal scrolling at high category counts. Selecting a category in code brings it into view. `SetSubTabAlignment` and removal reflow the capsule. Underlines are off for both subtabs and tabboxes.

The native header uses one 32 px centerline, 32 px utility hit targets, 16 px Lucide utility glyphs and 8 px gaps. The unread badge is anchored inside the bell's upper-right corner and grows leftwards through `99+`. No move icon is created. Four transparent 8 px edge bands reuse the native drag/snap lifecycle; the lower-right 32 px remains reserved for native resizing. Header dragging and Settings position/reset controls also remain available.

Logo, expanded sidebar icon and footer share `TabButtonsStyle.Padding + 12` as their left inset. Both ordinary and key-tab sidebar labels use native `TextTruncate.AtEnd` without wrapping, independent of Materials. Sidebar width changes retain the title's 32 px height. Scrollable group bodies and tabbox bodies sit 4 px inside the card rim; outer content columns reserve 8 px on the scrollbar side.

| CreateWindow setting | Default / behavior |
| --- | --- |
| `Font` | `Enum.Font.BuilderSansMedium`; explicit native Font/Enum overrides remain supported |
| `FontFamily` | Optional Roblox family content URI. Validated with `TextService:GetFamilyInfoAsync` in `pcall`; failure keeps the configured fallback font |
| `SidebarSubTabs` | `false`; explicit `true` retains Ultra's nested sidebar controller for legacy integrations |
| `SubTabUnderline` | `false`; explicit `true` retains the previous decorative underline |
| `FrameEdgeDrag` | `true`; disabling this retains ordinary header dragging |

Builder Sans is the default by explicit user agreement on 2026-10-11. SF Pro Text is not bundled in the inspected Roblox client. `FontFamily` remains available for project-supplied font family assets. A system font name cannot substitute for a Roblox-compatible family asset. The Imperium ThemeManager preset uses the same fallback; choosing/restoring a theme is an explicit font change. Typography weights continue to follow the family selected through the native font APIs.

Font-family loading reference: [Roblox TextService](https://create.roblox.com/docs/reference/engine/classes/TextService). `tests/navigation-system-smoke.lua` checks the reusable geometry, flat navigation, dynamic capsule, overflow, font availability, badge and pop-out insets. Pointer drag and click behavior must also be exercised in the live client.

## Shell and hover refinement (0.8)

The sidebar's single `PrimeSidebarPane` covers the full window height. Its header/navigation/footer children stay transparent even in opaque mode. A 1 px, 12% opacity seam fades at the top and bottom. The content-side header keeps its readable material independently, without repainting the left column. Logo and sidebar glyphs share a center axis; footer content follows the navigation's leading inset.

Search has a separate clipped shell, fixed 16 px icon and a bounded editable field with native ellipsis. Its full string and native search behavior remain intact. Header geometry reserves an 8 px gap before utility actions. Subcategory capsules default to the leading edge of the content area instead of floating in the middle; the alignment API remains available.

The symbolic capsule radius token stays 999. Roblox renders it as `UDim.new(0.5, 0)` for the main radius and all four corner radii, which scales with the actual short edge. Tabbox capsules have a 3 px inset around the selected segment. Hover lighting mirrors these corners and cancels the owner's content padding so its absolute bounds match the outer body. The gradient retains light at both ends rather than fading to empty, and passive input/slider/dropdown rows receive the same whole-body wash. No extra hit target or gameplay callback is added.

`tests/shell-polish-smoke.lua` checks the unified material in glass/opaque modes, long search clipping and action clearance, leading capsule alignment, hover extents, and capsule curvature. Runtime geometry is tested alongside native API, config and animation checks; this is not a claim of full assistive-technology or WCAG conformance.

## Capsule clearance and card rhythm (0.9)

Search retains its 32px input and centered glyph, inside a 36px clip shell with 2px clearance for its outline. The subcategory scroll viewport keeps 4px internal gutters on both ends, and selection auto-reveal preserves those gutters even at maximum overflow. Rounded geometry follows [Roblox UICorner](https://create.roblox.com/docs/reference/engine/classes/UICorner); the clipping ancestors must also reserve room for the stroke.

The header is 56px high: its controls remain centered at y=24, leaving 16px below them before the content. The material falloff begins below the controls. Sidebar and content origins, available height and sidebar-width updates all use the new header boundary.

Tabbox rails align 12px inside the card, matching field edges (4px scroll inset + 8px content padding). The rail starts at y=8, with 16px before the first field at y=56. Tab switching and reduced-motion paths retain the scroll body's x=4, y=48 inset. Auto-height and pop-out limits include the expanded header, content padding and bottom clearance. Group bodies use the same horizontal inset, with 10px top/bottom padding.

The shell regression checks clipped-outline clearance, header bottom padding and rail/field alignment across repeated tab changes, alongside existing feature and motion tests.
