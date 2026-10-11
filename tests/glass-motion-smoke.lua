-- Live UI-only regression checks; run after the bundled preview.
local L=assert(getgenv().ObsidianPrimeDemo)
local P=L.PrimePreview
local S=P.Showcase
local function check(ok,message) assert(ok,message);print("[Glass PASS]",message) end
local originalReduced=P.Appearance.ReducedMotion
local originalTab=L.ActiveTab
local ok,err=xpcall(function()
    P.Appearance:SetReducedMotion(false)
    local dividers,rims,shadows=0,0,0
    for _,object in ipairs(L.ScreenGui:GetDescendants()) do
        if object.Name=="ImperiumWindowDivider" or object.Name=="ImperiumSidebarDivider" then
            assert(object.BackgroundTransparency==1,"visible window divider")
            dividers+=1
        elseif object.Name=="ImperiumMaterialRim" then
            assert(object.Thickness==1 and object.Enabled,"invalid material rim")
            rims+=1
        elseif object.Name=="ImperiumSoftShadow" then
            assert(object.Transparency>=.9,"heavy shadow")
            shadows+=1
        end
    end
    check(dividers>=3 and rims>0 and shadows>0,"invisible window grid, 1px rims and soft card shadows")
    P.Tabs.Home:Show();task.wait(1)
    P.Tabs.Fishing:Show()
    check(P.Tabs.Fishing.Container.Position.X.Offset==0 and P.Tabs.Fishing.Container.Position.Y.Offset>0,"vertical tab entry")
    for i=1,12 do
        (i%2==0 and P.Tabs.Fishing or P.Tabs.Home):Show()
        task.wait(.025)
    end
    task.wait(1)
    check(P.Tabs.Fishing.Container.Visible and not P.Tabs.Home.Container.Visible,"rapid tab reversal selects only final content")
    check(P.Tabs.Fishing.Container.Position==UDim2.fromScale(0,0) and P.Tabs.Fishing.Container.GroupTransparency==0,"tab settles at rest")
    S.Tabs.Layouts:Show()
    local group=S.Groups.Collapsible
    for i=1,8 do group:SetCollapsed(i%2==1);task.wait(.025) end
    task.wait(1)
    check(not group.Collapsed and group.Container.Visible and not group.Holder.ClipsDescendants,"collapse reversal restores content and overflow")
    group:SetCollapsed(true);task.wait(1)
    check(not group.Container.Visible and not group.Holder.ClipsDescendants,"collapse completes without a stale clip")
    group:SetCollapsed(false);task.wait(1)
    local box=S.Groups.Tabbox
    box.Tabs.General:Show();task.wait(1)
    box.Tabs.Advanced:Show()
    check(box.Tabs.Advanced.Container.Parent:IsA("CanvasGroup") and box.Tabs.Advanced.Container.Parent.Position.Y.Offset>0,"tabbox uses vertical fade wrapper with native scrolling container")
    for i=1,8 do box.Tabs[i%2==0 and "Advanced" or "General"]:Show();task.wait(.025) end
    task.wait(1)
    check(box.ActiveTab==box.Tabs.Advanced and not box.Tabs.General.Container.Visible and box.Tabs.Advanced.Container.Position==UDim2.fromOffset(4,48),"tabbox reversal and vertical settling")
    S.Tabs.Components:Show()
    S.Tabs.Components.SubTabs.Inputs:Hover(true);task.wait(.3)
    for _,object in ipairs(S.Tabs.Components.SubTabs.Inputs.Button:GetDescendants()) do
        if object:IsA("UIScale") then assert(object.Scale==1,"subtab text shrank") end
    end
    S.Tabs.Components.SubTabs.Inputs:Hover(false)
    check(true,"subtab hover preserves text scale")
    P.Appearance:SetReducedMotion(true)
    P.Tabs.Home:Show();P.Tabs.Fishing:Show()
    group:SetCollapsed(true)
    check(not group.Container.Visible and not group.Holder.ClipsDescendants and P.Tabs.Fishing.Container.GroupTransparency==0,"reduced motion settles synchronously")
    group:SetCollapsed(false)
    P.Appearance:SetReducedMotion(false)
    L.Window:SetMinimized(true);task.wait(.04);L.Window:SetMinimized(false);task.wait(.04)
    L.Window:SetMinimized(true);task.wait(.04);L.Window:SetMinimized(false);task.wait(1)
    check(L.Window.MainFrame.Visible and L.Window.MainFrame.GroupTransparency==0,"rapid minimize reversal restores the window")
end,debug.traceback)
P.Appearance:SetReducedMotion(originalReduced)
if originalTab then originalTab:Show() end
if not ok then error(err,0) end
print("[Glass MOTION COMPLETE]")
