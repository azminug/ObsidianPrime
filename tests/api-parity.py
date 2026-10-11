"""Structural regression guard against the pinned Ultra baseline, not a behavior proof."""
from pathlib import Path
import re
import subprocess

root = Path(__file__).resolve().parent.parent
pattern = r"function\s+([A-Za-z_][\w.]*(?::[A-Za-z_]\w*)?)\s*\("
for path in ("Library.lua", "addons/SaveManager.lua", "addons/ThemeManager.lua"):
    old = subprocess.check_output(["git", "show", f"obsidian-ultra-baseline:{path}"], cwd=root, text=True, encoding="utf-8")
    new = (root / path).read_text(encoding="utf-8")
    expected, actual = set(re.findall(pattern, old)), set(re.findall(pattern, new))
    assert not expected - actual, (path, sorted(expected - actual))
    print(f"PASS {path}: all {len(expected)} named function entries retained")

demo = (root / "ImperiumDemo.lua").read_text(encoding="utf-8") + (root / "addons/Showcase.lua").read_text(encoding="utf-8")
constructors = {name.split(":")[-1] for name in re.findall(pattern, (root / "Library.lua").read_text(encoding="utf-8")) if name.startswith("Funcs:Add")}
for name in constructors:
    assert f":{name}(" in demo, f"Missing native element showcase: {name}"
print(f"PASS preview: all {len(constructors)} native Funcs:Add constructors represented")
