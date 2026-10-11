# Imperium UI design requirements

All UI/UX changes target WCAG 2.2 Level AA and its four POUR principles:
Perceivable, Operable, Understandable, Robust. Use the official reference:
https://www.w3.org/WAI/WCAG22/quickref/

- Cosmic base is HEX #23212C, RGB (35, 33, 44). The user's alternative RGB
  (35, 35, 44) differs; HEX is the implemented source of truth.
- Typography uses Builder Sans by explicit user agreement (2026-10-11).
  Keep SemiBold titles, Medium labels, and Regular values; never label it as SF Pro.
- Prefer legible translucent panels, stable semantic colors, explicit status
  words, and visible keyboard focus. Do not depend on color or hover alone.
- Check normal text at >=4.5:1 and meaningful non-text boundaries at >=3:1,
  including the brightest possible backdrop for glass surfaces.
- Provide non-drag alternatives, touch targets >=24 logical units (prefer 32–44),
  reduced motion, opaque background, and clear errors with recovery instructions.
- Validate new transition behavior under rapid reversal, hide/show, re-execute,
  reduced motion, and unload. Avoid perpetual cosmetic render loops.
- Do not claim WCAG conformance from token contrast tests or mocked GUI tests.
  Record unverified keyboard, touch, zoom, reflow, and assistive-tech behavior in
  ACCESSIBILITY.md. Roblox UI lacks web DOM/ARIA semantics.
- Preserve the upstream license and public APIs. Do not execute gameplay actions
  from UI previews or silently replace production script settings.
- Preserve all upstream capability families in the feature workbench. Visual changes
  must not disable native defaults such as collapse/pop-out or hide minimized-label APIs.
- Shared materials must cover lazily created popups and respect ThemeManager,
  opaque mode, control state, and per-component destruction. Run the baseline
  function inventory and live workbench smoke before calling a build compatible.
