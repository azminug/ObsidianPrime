"""WCAG sRGB contrast checks for the default Cosmic palette (not a full UI audit)."""
def rgb(hex_color):
    return tuple(int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4))

def blend(front, back, opacity):
    return tuple(f * opacity + b * (1 - opacity) for f, b in zip(front, back))

def luminance(color):
    linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in color]
    return sum(c * w for c, w in zip(linear, (0.2126, 0.7152, 0.0722)))

def contrast(a, b):
    hi, lo = sorted((luminance(a), luminance(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)

# Source values mirror Frosted 0.6; white is the brightest backdrop.
white = (1, 1, 1)
main_color = blend(rgb("23212c"), rgb("f7f3fa"), .91)
material_color = blend(rgb("2f2c3a"), rgb("f7f3fa"), .86)
main = blend(main_color, white, 0.52)
panel = blend(material_color, main, 0.64)
header = blend(material_color, main, 0.65)
dock = blend(rgb("23212c"), white, 0.75)
selection = blend(rgb("23212c"), blend(rgb("91809f"), main, .62), .35)
cases = [
    ("selected sidebar text", rgb("f7f3fa"), selection, 4.5),
    ("glass panel body", rgb("f7f3fa"), panel, 4.5),
    ("glass panel muted (10%)", blend(rgb("f7f3fa"), panel, .9), panel, 4.5),
    ("parameter lavender", blend(rgb("f7f3fa"),rgb("ddb7db"),.87), panel, 4.5),
    ("glass header body", rgb("f7f3fa"), header, 4.5),
    ("capsule telemetry", rgb("ded5e8"), dock, 4.5),
    ("slider knob", rgb("ddb7db"), panel, 3),
    ("slider track", blend(rgb("f7f3fa"), panel, .75), panel, 3),
    ("opaque panel text", rgb("f7f3fa"), rgb("4c465c"), 4.5),
]
popup=blend(material_color, white, .8)
raised_popup=blend(material_color,white,.92)
cases.append(("raised menu value",blend(rgb("f7f3fa"),rgb("ddb7db"),.87),raised_popup,4.5))
for kind,token in [("error","ffeef2"),("warning","fff6e0"),("success","e6ffeb"),("info","ebf2ff")]:
    cases.append(("popup " + kind + " text",rgb(token),popup,4.5))
for name, foreground, surface, minimum in cases:
    ratio = contrast(foreground, surface)
    print(f"{name:28}: {ratio:.2f}:1 (minimum {minimum})")
    assert ratio >= minimum, (name, ratio)
# A decorative, empty part of the window is intentionally more transparent.
# Do not use this surface directly behind text or claim a complete AA audit.
print(f"Bare shell text: {contrast(rgb('f7f3fa'), main):.2f}:1; protected text surfaces required")
