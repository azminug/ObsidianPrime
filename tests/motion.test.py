"""Run the real Luau spring source with a controlled clock and numeric targets."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
source = (root / "addons/Motion.lua").read_text(encoding="utf-8")
harness = '''
local signal = { Connections = {} }
function signal:Connect(fn)
    local c = { Connected = true, fn = fn }
    function c:Disconnect() self.Connected = false end
    table.insert(self.Connections, c)
    return c
end
local game = { GetService = function() return { RenderStepped = signal } end }
local task = { defer = function(fn) fn() end }
local function tick(n)
    for _=1,n do for _,c in signal.Connections do if c.Connected then c.fn(1/60) end end end
end
local Motion = (function()
''' + source + '''
end)()
local motion = Motion.new()
local object = { Parent = true, Scale = 0 }
motion:To(object, { Scale = 1 }, 24, 0.7)
tick(120)
assert(math.abs(object.Scale-1)<0.001, "spring must settle")
assert(not signal.Connections[1].Connected, "no idle render loop")
motion:To(object, { Scale = 0 }, 24, 0.8)
tick(3)
motion:To(object, { Scale = 2 }, 24, 0.8)
tick(120)
assert(math.abs(object.Scale-2)<0.001, "latest target must win")
motion:To(object, { Scale = 1 }, 24, 0.8)
motion:SetReduced(true)
assert(object.Scale==1, "reduced motion settles immediately")
motion:SetReduced(false)
motion:To(object, { Scale = 0 }, 24, 0.8)
motion:Destroy()
local previous = object.Scale
tick(120)
assert(object.Scale==previous, "unload stops movement")
print("PASS: spring settle, latest target, idle disconnect, reduced motion, destruction")
'''
path = Path(tempfile.gettempdir()) / "prime-motion-test.luau"
path.write_text(harness, encoding="utf-8")
subprocess.run([str(Path(os.environ["TEMP"]) / "imperium-luau-tools/luau.exe"), str(path)], check=True)
