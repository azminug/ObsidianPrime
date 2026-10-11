-- Checks whole-control geometry, clipping and a single sidebar material.
local L=assert(getgenv().ObsidianPrimeDemo)
local P=L.PrimePreview
local main=L.Window.MainFrame
local previous=L.ActiveTab
local function find(root,name) return assert(root:FindFirstChild(name,true),name) end
local function near(a,b) return math.abs(a-b)<1 end
local function check(ok,msg) assert(ok,msg);print("[Shell PASS]",msg) end
local search=find(main,"PrimeHeaderSearch")
local text=search.Text
local shell=find(main,"PrimeSearchShell")
local originalSize=main.Size
local ok,err=xpcall(function()
    local pane=find(main,"PrimeSidebarPane")
    local sidebar=find(main,"PrimeSidebar")
    local header=find(main,"PrimeHeader")
    check(pane.AbsolutePosition==main.AbsolutePosition and near(pane.AbsoluteSize.Y,main.AbsoluteSize.Y)
        and sidebar.BackgroundTransparency==1 and header.BackgroundTransparency==1,"one uninterrupted sidebar material")
    local line=find(pane,"PrimeSidebarHairline")
    check(line.Size.X.Offset==1 and line.BackgroundTransparency>=.85,"subtle one-pixel sidebar seam")
    P.Materials:SetOpaque(true)
    check(sidebar.BackgroundTransparency==1 and header.BackgroundTransparency==1 and pane.BackgroundTransparency==0,"opaque mode preserves unified sidebar")
    P.Materials:SetOpaque(false)
    local bell=find(main,"PrimeHeaderBell")
    search.Text=string.rep("Very long search content ",20);task.wait(.3)
    check(search.TextTruncate==Enum.TextTruncate.AtEnd and search.ClipsDescendants and shell.ClipsDescendants
        and shell.AbsolutePosition.X+shell.AbsoluteSize.X<=bell.AbsolutePosition.X-8*L.DPIScale,"search remains within clipped viewport and reserved action gap")
    search.Text=text;task.wait(.3)
    P.Showcase.Tabs.Components:Show();task.wait(.5)
    local recess=find(P.Showcase.Tabs.Components.Container,"PrimeRecess")
    local bar=find(P.Showcase.Tabs.Components.Container,"PrimeSubcategoryBar")
    check(near(recess.AbsolutePosition.X,bar.AbsolutePosition.X),"subcategory capsule starts at content leading edge")
    check(search.AbsolutePosition.X-shell.AbsolutePosition.X>=1.9*L.DPIScale
        and search.AbsolutePosition.Y-shell.AbsolutePosition.Y>=1.9*L.DPIScale
        and shell.AbsolutePosition.X+shell.AbsoluteSize.X-search.AbsolutePosition.X-search.AbsoluteSize.X>=1.9*L.DPIScale,
        "search outline has two-pixel clip clearance")
    check(header.AbsolutePosition.Y+header.AbsoluteSize.Y-search.AbsolutePosition.Y-search.AbsoluteSize.Y>=15.9*L.DPIScale,
        "header reserves sixteen pixels below controls")
    local viewport=find(bar,"PrimeSubcategoryViewport")
    local pad=viewport:FindFirstChildOfClass("UIPadding")
    check(pad and pad.PaddingLeft.Offset==4 and pad.PaddingRight.Offset==4,"scrolling capsules reserve outline gutters")
    P.Showcase.Tabs.Layouts:Show();task.wait(.4)
    local box=P.Showcase.Groups.Tabbox
    local original=box.ActiveTab
    for _,tab in ipairs({box.Tabs.General,box.Tabs.Advanced,box.Tabs.General}) do
        tab:Show();task.wait(.5)
        local body=tab.Container
        local rail=box.Holder:FindFirstChild("PrimeRecess")
        local inset=body:FindFirstChildOfClass("UIPadding")
        check(near(body.AbsolutePosition.X-box.Holder.AbsolutePosition.X,4*L.DPIScale)
            and near(body.AbsolutePosition.X+inset.PaddingLeft.Offset*L.DPIScale,rail.AbsolutePosition.X),
            "tab switch preserves matching rail and input leading edges")
        check(body.AbsolutePosition.Y+inset.PaddingTop.Offset*L.DPIScale-rail.AbsolutePosition.Y-rail.AbsoluteSize.Y>=15.9*L.DPIScale,
            "tab rail and fields retain sixteen-pixel vertical gap")
    end
    if original then original:Show() end
    local count,rows=0,0
    for _,object in ipairs(main:GetDescendants()) do
        if object.Name=="ImperiumSpecular" and object.Parent.AbsoluteSize.X>0 then
            local owner=object.Parent
            assert(near(object.AbsolutePosition.X,owner.AbsolutePosition.X) and near(object.AbsolutePosition.Y,owner.AbsolutePosition.Y)
                and near(object.AbsoluteSize.X,owner.AbsoluteSize.X) and near(object.AbsoluteSize.Y,owner.AbsoluteSize.Y),"full-body hover "..owner.Name)
            if owner.Name=="PrimeSettingRow" then rows+=1 end
            if owner:GetAttribute("ImperiumRadius")==999 then
                check(object:FindFirstChildOfClass("UICorner").CornerRadius==UDim.new(.5,0),"hover follows capsule curvature")
            end
            count+=1
        end
    end
    check(count>20 and rows>3,"buttons and setting rows share whole-body hover")
    check(recess:FindFirstChildOfClass("UICorner").CornerRadius==UDim.new(.5,0),"capsule radius resolves to half its height")
end,debug.traceback)
search.Text=text
P.Materials:SetOpaque(false)
if previous then previous:Show() end
if not ok then error(err,0) end
print("[Shell SMOKE COMPLETE]")
