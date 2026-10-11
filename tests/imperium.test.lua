-- Run from the repository root with Lua. Tests state rendering, not Roblox UI.
local Imperium = dofile("addons/Imperium.lua")
workspace = { CurrentCamera = { ViewportSize = { X = 600 } } }
local unload, updates, detailUpdates, subtitleUpdates = nil, 0, 0, 0
local Library = { IsMobile = false, NotificationTypeColors = { Success = "green", Warning = "amber", Error = "red" },
    Scheme = { OutlineColor = "gray" }, OnUnload = function(_, callback) unload = callback end }
local Window = {
    AddTab = function(_, info) return info end,
    SetAnimations = function(self, flags) self.Flags = flags end,
    SetMinimizedSubtitle = function(self, value) self.Subtitle = value; subtitleUpdates = subtitleUpdates + 1 end,
}
local group = {
    AddStatusLabel = function() return { SetItems = function(_, items) updates = updates + 1; assert(items[1].StatusColor) end } end,
    AddLabel = function() return { SetText = function() detailUpdates = detailUpdates + 1 end } end,
}
local prime = Imperium.new(Library, Window)
assert(prime:AddTab("Test", "home").SingleColumn)
local activity = prime:AddActivity(group, "Test", "Fusion")
activity:SetState("Waiting", "Need ingredients")
activity:SetState("Waiting", "Need ingredients")
assert(updates == 1 and detailUpdates == 1, "Identical states must not redraw")
activity:SetState("Waiting", "Need one more")
assert(updates == 1 and detailUpdates == 2, "Detail-only update")
assert(not pcall(function() activity:SetState("Invalid") end))
prime:SetReducedMotion(true)
for _, enabled in pairs(Window.Flags) do assert(enabled == false) end
prime:SetReducedMotion(false)
assert(Window.Flags.TabSwitch and not Window.Flags.Groupbox)
prime:SetSessionStatus("Waiting")
prime:SetSessionStatus("Waiting")
assert(subtitleUpdates == 1)
unload()
activity:SetState("Running", "Processing")
prime:SetSessionStatus("Running")
assert(updates == 1 and detailUpdates == 2 and subtitleUpdates == 1, "Unload must stop updates")
workspace.CurrentCamera.ViewportSize.X = 1200
assert(not Imperium.new(Library, Window):AddTab("Desktop", "home").SingleColumn)
print("PASS: responsive initial layout, state rendering, deduplication, reduced motion, unload")
