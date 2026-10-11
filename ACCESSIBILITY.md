# Cosmic preview accessibility status

Target: WCAG 2.2 AA / POUR. This is an implementation target, not a conformance claim.
Reference: https://www.w3.org/WAI/WCAG22/quickref/

## Implemented

- Perceivable: cosmic #23212C, high-contrast foregrounds, clearer inactive text,
  opaque option, explicit activity words/reasons, and UI scaling up to 200%.
- Operable: native button activation shared with keyboard callbacks, visible focus,
  Tab/Shift+Tab navigation through visible registered buttons/textboxes, Enter/Space
  activation, Escape focus release, Ctrl+M minimize/restore, Ctrl+Home centering,
  position buttons, dock corner selection, and non-drag priority reordering.
  Slider focus can open exact numeric entry when its input option is enabled.
- Understandable: stable mini status, named material/motion settings, configuration
  controls marked as a preview, and clear missing-local-file errors.
- Robust: unchanged upstream methods plus optional composition modules, cancellation
  of stale transitions, signal cleanup, repeat execution cleanup, and Luau checks.

New dock target is 320x38 logical units. Main buttons, switches, checkboxes, inputs,
and standard dropdown display controls are 32 high; slider tracks are 28 high.
Other inherited controls require a complete target/spacing audit.

## Verified without Roblox

- `python tests/contrast.py`: actual 0.4 surface alpha composited over white. Panel text 5.31:1, 10% muted text 4.67:1, header text 5.37:1, capsule telemetry 4.90:1, slider knob 3.29:1, track 3.80:1. These are token/material checks, not all rendered states.
- `python tests/motion.test.py`: actual spring source, settling, interrupted targets, idle disconnect, reduced motion, destruction.
- `lua tests/cosmic.test.lua`: latest-request-wins transitions, rapid reversal,
  reduced motion, hide during transitions, shadow/opaque options, and unload.
- `lua tests/imperium.test.lua`: state rendering, deduplication, initial compact layout.
- Luau compilation at -O0.

## Live validation (2026-10-10, PID 13276)

Executed the actual bundled preview using Potassium. Inspected the Roblox rendering, clicked the Fishing sidebar, and dragged the capsule with native input. Runtime assertions passed for tab activation, minimize/restore, rapid reversal, reduced motion, opaque material, slider values, and blur disabling while minimized. Repeat execution replaced this preview's previous instance.

## Audit still required

0.6 adds width-based button/label/value ellipsis, eight-pixel field spacing, 28–32 px targets for header/expand/collapse/addon controls, 1 px focus rings, and event-driven overlay scrollbars. Parameter lavender tests at 5.01:1 over the brightest tested group fill, and raised-menu parameter text at 6.12:1. Decorative rims fade from 28% to 9% opacity; this is not a claim that every control boundary meets 3:1. Truncation preserves underlying strings; complete accessible naming and touch discovery still require platform testing.

0.5 (2026-10-11, PID 26184) adds vertical, critically damped tab/tabbox and collapse motion, rapid-reversal guards, and stable text sizing during button/subtab interaction. Window grid lines are decorative and removed visually; the sidebar resize target remains. One-pixel rims and soft shadows are decorative, not a substitute for accessible control boundaries. Token contrast values are unchanged from 0.4. The new sheen only darkens the group fill, so the existing brightest-fill calculation remains conservative.

- Keyboard reachability/order for every popup, scrolled list, slider, color picker,
  confirmation action, and nested tab. Current Tab navigation skips clipped controls;
  scrolling and modal focus containment are not a complete accessible traversal yet.
- Persistent hover/focus content and Escape dismissal for inherited Ultra tooltips.
- Full 200% scaling and reflow on small viewports. A scale control alone does not
  guarantee no clipping, and initial single-column layout is not dynamic reflow.
- All target sizes and spacing at actual DPI, especially legacy icon buttons.
- Text/icon contrast in every state and alternate theme. Palette checks do not
  prove contrast for every composited/translucent control or disabled state.
- Screen-reader name/role/value and announcements: Roblox/executor support must
  be established. No web ARIA or equivalent semantic guarantee is claimed.
- Focus must remain unobscured during scrolling, minimizing, and opening dialogs.

Reduced motion stops Cosmic drag/dock/minimize transitions and the exposed Ultra
animation flags. Existing fixed-duration hover/tooltips may still animate.
The glass is tinted transparency plus a camera-local BlurEffect and glass/DOF treatment. Blur covers the 3D world while the menu is visible; the separate game HUD does not blur. An opaque option removes this dependency. The bare decorative shell is too transparent for normal text on a white scene (2.70:1), so content uses stronger local surfaces. Inherited icons, translucent outlines, transient hover states, tooltip text, popup states, and alternate themes still require individual checks. The existence of an opaque option is not proof of full AA compliance.

## 0.4 expanded coverage

The shared Materials layer also covers lazy history, context menus, pop-outs and loading surfaces. Notification semantic text now uses pale colors (4.55:1–4.84:1 over the selected popup material on white); type words remain available. Native collapse/pop-out and minimized-label capabilities are retained. See FEATURES.md for the live feature tests. The broader workbench exposes inherited states that still need the keyboard, target-size, disabled-text, zoom and assistive-technology audits listed above.

0.7 introduces a single default controller per subcategory, native ellipsis for sidebar labels, scrollable category overflow, inset card scrollbars, and consistent header geometry. Edge drag bands are precision pointer targets (8 px), not replacements for the existing non-drag position/reset controls. Actual SF Pro Text remains dependent on a project-supplied available font asset; Builder Sans is the verified fallback. Full keyboard/gamepad/touch navigation and large text reflow remain unverified; this build is not certified WCAG AA.

0.8 uses the explicitly approved Builder Sans default. Search retains the full query while clipping its presentation; navigation remains flat and overflow remains reachable. The sidebar seam is decorative. Whole-body hover is supplemental feedback, not the only indicator of state. Current muted text over bright glass during hover is not proven to meet 4.5:1 in every state; opaque mode is available, and a complete state-by-state contrast audit remains outstanding. Header contrast calculations refer to the content-side protected header surface, not bare window glass.

## 0.10 application composition

Item details open on activation rather than hover; 44px list rows retain selection markers as well as color. Search reports no matches, and bulk actions apply only to visible rows. Dialogs keep a solid Cosmic backplate independent of the shell opacity. Narrow application columns stack at 580 logical content pixels; wider layouts restore their original sides. These checks cover executor rendering and callbacks, not physical touch, screen-reader announcements, every theme, or 200% scaling.
