-- UI-only live regression: design tokens, geometry, focus, scrolling and overflow.
local L=assert(getgenv().ObsidianPrimeDemo)
local P=L.PrimePreview
local O,T=L.Options,L.Toggles
local function check(ok,message) assert(ok,message);print("[Components PASS]",message) end
local function near(a,b) return math.abs(a-b)<.1 end
local function find(root,name) return assert(root:FindFirstChild(name,true),name) end
local previous=L.ActiveTab
local oldToggle=T.UltraToggle.Value
local oldName=T.UltraToggle.Text
local oldScroll,oldNavSize
local ok,err=xpcall(function()
    P.Showcase.Tabs.Components:Show();task.wait(1)
    local main=L.Window.MainFrame
    local group=P.Showcase.Groups.Collapsible.Holder
    check(main:FindFirstChildOfClass("UICorner").CornerRadius.Offset==16 and group:FindFirstChildOfClass("UICorner").CornerRadius.Offset==12,"window/card radius hierarchy")
    local rim=find(group,"ImperiumMaterialRim")
    local grad=rim:FindFirstChildOfClass("UIGradient")
    check(rim.Thickness==1 and rim.Transparency==0 and grad.Rotation==90 and near(grad.Transparency.Keypoints[1].Value,.72) and near(grad.Transparency.Keypoints[2].Value,.91),"one-pixel rim: 28% top to 9% bottom")
    local material=P.Materials
    local oldRadius=L.CornerRadius
    material:SetRadiusHierarchy(false);L.Window:SetCornerRadius(10);task.wait(.1)
    check(main:FindFirstChildOfClass("UICorner").CornerRadius.Offset==10,"native radius override remains available")
    L.Window:SetCornerRadius(oldRadius);material:SetRadiusHierarchy(true);task.wait(.1)
    check(main:FindFirstChildOfClass("UICorner").CornerRadius.Offset==16 and group:FindFirstChildOfClass("UICorner").CornerRadius.Offset==12,"radius hierarchy restores")
    local recess=find(P.Showcase.Tabs.Components.Container,"PrimeRecess")
    check(recess.AbsoluteSize.X>100 and recess:FindFirstChildOfClass("UICorner").CornerRadius==UDim.new(.5,0),"unified recessed capsule")
    local slider=O.UltraSlider.Holder
    local label=find(slider,"PrimeLabel")
    local thumb=find(slider,"PrimeSliderThumb")
    local track=find(slider,"PrimeSliderTrack")
    check(track.Size.Y.Offset==4 and thumb.Size.X.Offset==14 and thumb.Size.Y.Offset==14 and (thumb.AbsolutePosition.Y-label.AbsolutePosition.Y-label.AbsoluteSize.Y)/L.DPIScale>=6,"slider geometry and label clearance")
    local row=T.UltraToggle.Holder
    local switch=find(row,"PrimeSwitch")
    local ball=find(row,"PrimeSwitchThumb")
    T.UltraToggle:SetValue(false);task.wait(.6)
    check(near((ball.AbsolutePosition.X-switch.AbsolutePosition.X)/L.DPIScale,2) and near((ball.AbsolutePosition.Y-switch.AbsolutePosition.Y)/L.DPIScale,2),"toggle off inset two pixels")
    T.UltraToggle:SetValue(true);task.wait(.6)
    check(near((switch.AbsolutePosition.X+switch.AbsoluteSize.X-ball.AbsolutePosition.X-ball.AbsoluteSize.X)/L.DPIScale,2),"toggle on inset two pixels")
    T.UltraToggle:SetText("A long feature label that must never overlap the keybind and color controls")
    task.wait(.2)
    local text=T.UltraToggle.TextLabel
    check(text.TextTruncate==Enum.TextTruncate.AtEnd and text.AbsolutePosition.X+text.AbsoluteSize.X<=T.UltraToggle.AddonsHolder.AbsolutePosition.X,"label truncation reserves addon space")
    local input=O.UltraText and O.UltraText.Holder or O.PrimeMessage.Holder
    local box=input:FindFirstChildWhichIsA("TextBox",true)
    check(box.FontFace.Weight==Enum.FontWeight.Regular,"parameter font uses Regular")
    local title=find(group,"PrimeTitle")
    check(title.FontFace.Weight==Enum.FontWeight.SemiBold and text.FontFace.Weight==Enum.FontWeight.Medium,"title and label font weights")
    local sample=O.PrimeMessage.Holder
    local field=sample:FindFirstChildWhichIsA("TextBox",true)
    local fieldLabel=find(sample,"PrimeLabel")
    check(near((field.AbsolutePosition.Y-fieldLabel.AbsolutePosition.Y-fieldLabel.AbsoluteSize.Y)/L.DPIScale,8),"input label-to-field spacing eight pixels")
    local nav=find(main,"PrimeSidebar")
    local clip=find(main,"ImperiumNavigationClip")
    local selection=find(clip,"CosmicSelection")
    oldScroll=nav.CanvasPosition
    check(clip.ClipsDescendants and selection.Parent==clip and clip.AbsolutePosition==nav.AbsolutePosition and clip.AbsoluteSize==nav.AbsoluteSize,"selection clipped to navigation viewport")
    oldNavSize=nav.Size;nav.Size=UDim2.new(nav.Size.X.Scale,nav.Size.X.Offset,0,160);task.wait(.1)
    nav.CanvasPosition=Vector2.new(0,30);task.wait(.2)
    check(nav.ScrollBarThickness==3 and nav.ScrollBarImageTransparency<.9,"scrollbar reveals at three pixels")
    task.wait(1.6)
    check(nav.ScrollBarImageTransparency>.99,"scrollbar fades when idle")
    nav.Size=oldNavSize
    for _,name in ipairs({"PrimeHeaderTitle","PrimeHeaderSearch","PrimeHeaderMinimize","PrimeHeaderBell"}) do
        local control=find(main,name)
        check(near(control.AbsoluteSize.Y/L.DPIScale,32),name.." height 32")
    end
    local bell,mini=find(main,"PrimeHeaderBell"),find(main,"PrimeHeaderMinimize")
    check(near((mini.AbsolutePosition.X-bell.AbsolutePosition.X-bell.AbsoluteSize.X)/L.DPIScale,8),"header icon gaps eight pixels")
    P.Showcase.Tabs.Components.SubTabs.Choices:Show();task.wait(.6)
    for _,opt in ipairs({O.UltraSingle,O.UltraPriority}) do
        local control=find(opt.Holder,"PrimeDropdownControl")
        local value=find(control,"PrimeValue")
        check(near(value.AbsolutePosition.Y+value.AbsoluteSize.Y/2,control.AbsolutePosition.Y+control.AbsoluteSize.Y/2),"dropdown value vertically centered")
        local glyph=find(control,"PrimeExpandGlyph")
        check(glyph.Size.X.Offset==14 and glyph.Parent.AbsoluteSize.X/L.DPIScale>=28,"expand glyph 14 with 28 pixel hit target")
        local arrow=find(control,"PrimeDropdownChevron")
        opt.Menu:Open();task.wait(.6)
        check(near(arrow.Rotation,0) and opt.Menu.Menu.BackgroundTransparency<=.081,"open chevron and raised popup opacity")
        opt.Menu:Close();task.wait(.6)
        check(near(arrow.Rotation,180),"close chevron settles at 180 degrees")
    end
    P.Tabs.Fishing:Show();task.wait(.6)
    field:CaptureFocus();task.wait(.6)
    check(field:IsFocused() and find(field,"ImperiumFocusRing").Transparency<.01,"focused input ring visible")
    field:ReleaseFocus();task.wait(.6)
    check(find(field,"ImperiumFocusRing").Transparency>.99,"input ring clears after focus")
    local count=0
    for _,object in ipairs(main:GetDescendants()) do
        if object.Name=="PrimeActionButton" then
            assert(object.TextTruncate==Enum.TextTruncate.AtEnd and not object.TextWrapped,"button overflow")
            count+=1
        end
    end
    check(count>10,"native action buttons truncate without wrapping")
end,debug.traceback)
T.UltraToggle:SetValue(oldToggle);T.UltraToggle:SetText(oldName)
if oldNavSize then find(L.Window.MainFrame,"PrimeSidebar").Size=oldNavSize end
if oldScroll then find(L.Window.MainFrame,"PrimeSidebar").CanvasPosition=oldScroll end
if previous then previous:Show() end
if not ok then error(err,0) end
print("[Components SMOKE COMPLETE]")
