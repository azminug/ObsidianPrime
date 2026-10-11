from pathlib import Path

root = Path(__file__).resolve().parent.parent
modules = ["Library.lua", "addons/Imperium.lua", "addons/Cosmic.lua", "addons/Motion.lua", "addons/Acrylic.lua", "addons/Materials.lua", "addons/Showcase.lua", "addons/SaveManager.lua", "addons/ThemeManager.lua"]
parts = ["local sources = {}"]
for module in modules:
    source = (root / module).read_text(encoding="utf-8")
    assert "]====]" not in source
    parts.append(f'sources["{module}"] = [====[{source}]====]')
demo = (root / "ImperiumDemo.lua").read_text(encoding="utf-8")
demo = demo.replace('readfile("ObsidianPrime/" .. path)', 'assert(sources[path], "Missing bundled module: " .. path)')
parts.extend([demo, "-- PRIME_BUNDLE_END\n"])
(root / "ImperiumPreview.bundle.lua").write_bytes("\n".join(parts).encode("utf-8"))
print("Built standalone ImperiumPreview.bundle.lua")
