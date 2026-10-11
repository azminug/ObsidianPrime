-- Native Ultra feature workbench. All actions stay inside this UI preview.
local Showcase = {}
function Showcase.build(Library, Window, fetch, Appearance)
    local self={Tabs={},Groups={},Owned={},Alive=true}
    local O,T=Library.Options,Library.Toggles
    local function own(object) self.Owned[#self.Owned+1]=object;return object end
    local function tab(name,icon) local t=Window:AddTab(name,icon);self.Tabs[name]=t;return t end
    local function group(t,side,name) return t:AddGroupbox({Side=side,Name=name}) end
    local function notify(text) Library:Notify({Title="Imperium",Description=text,Time=4}) end
    local components=tab("Components","sliders-horizontal")
    local inputs=components:AddSubTab("Inputs","toggle-right")
    local choices=components:AddSubTab("Choices","list-filter")
    local basic=group(inputs,"Left","Controls & addons")
    basic:AddToggle("UltraToggle",{Text="Switch",Default=false,Tooltip="Native switch with its original callback and config support."})
        :AddKeyPicker("UltraToggleKey",{Text="Preview switch",Default="F6",Mode="Toggle",SyncToggleState=true})
        :AddColorPicker("UltraColor",{Title="Color and alpha",Default=Color3.fromRGB(221,183,219),Transparency=.2})
    basic:AddCheckbox("UltraCheckbox",{Text="Checkbox",Default=true})
    basic:AddInput("UltraText",{Text="Live text",Default="Imperium",Finished=false})
    basic:AddInput("UltraNumber",{Text="Numeric input",Default="25",Numeric=true,Finished=true})
    basic:AddSlider("UltraSlider",{Text="Precise slider",Default=25,Min=0,Max=100,Rounding=1,Suffix="%",AllowRightClickInput=true})
    basic:AddSlider("UltraCompact",{Text="Compact slider",Default=3,Min=0,Max=10,Rounding=0,Compact=true,AllowRightClickInput=true})
    local state=group(inputs,"Right","Actions & states")
    local count=0
    local counter=state:AddLabel("Callback count: 0",true)
    local function increment() count+=1;counter:SetText("Callback count: "..count) end
    state:AddButton({Text="Primary action",Func=increment}):AddButton({Text="Sub-button",Func=increment})
    state:AddButton({Text="Double-click action",DoubleClick=true,Func=increment})
    local disabled=state:AddButton({Text="Disabled action",Disabled=true,DisabledTooltip="Enable with the switch below.",Func=increment})
    state:AddToggle("UltraEnableButton",{Text="Enable action",Default=false,Callback=function(v) disabled:SetDisabled(not v) end})
    state:AddLabel("Press key"):AddKeyPicker("UltraPressKey",{Default="F7",Mode="Press",Text="Count UI action",Callback=increment})
    state:AddToggle("UltraShowKeybinds",{Text="Keybind panel",Default=false,Callback=function(v) Library.KeybindFrame.Visible=v end})
    state:AddDivider("Dependencies")
    state:AddToggle("UltraDependency",{Text="Show dependent controls",Default=false})
    local dependency=state:AddDependencyBox()
    dependency:AddInput("UltraDependentText",{Text="Dependent input",Default="Visible only when enabled"})
    dependency:SetupDependencies({{T.UltraDependency,true}})
    local depGroup=basic:AddDependencyGroupbox()
    depGroup:AddLabel("Dependent groupbox is available too.",true)
    depGroup:SetupDependencies({{T.UltraDependency,true}})
    local lists=group(choices,"Left","Selection menus")
    lists:AddDropdown("UltraSingle",{Text="Single",Values={"Balanced","Quality","Performance"},Default=1,Searchable=true,Expandable=true})
    lists:AddDropdown("UltraMulti",{Text="Multiple",Values={"Common","Rare","Legendary"},Default={"Rare"},Multi=true,Searchable=true})
    lists:AddDropdown("UltraDictionary",{Text="Stable IDs",Values={calm="Calm water",deep="Deep sea",coast="Coast"},Default="calm"})
    lists:AddDropdown("UltraPlayers",{Text="Players (live)",SpecialType="Player"})
    lists:AddDropdown("UltraTeams",{Text="Teams (live)",SpecialType="Team"})
    local priority=group(choices,"Right","Priority & dynamic values")
    priority:AddPriorityDropdown("UltraPriority",{Text="Priority order",Values={"Safety","Quality","Speed"},Default={"Quality","Safety","Speed"},Searchable=true,Expandable=true})
    priority:AddButton({Text="Restore priority",Func=function() O.UltraPriority:SetValue({"Quality","Safety","Speed"}) end})
    local expanded=false
    priority:AddButton({Text="Change dropdown catalog",Func=function()
        expanded=not expanded
        O.UltraSingle:SetValues(expanded and {"Balanced","Quality","Performance","Custom"} or {"Balanced","Quality","Performance"})
    end})
    priority:AddLabel("Dropdown expansion, search, multi-selection and priority reordering use the native Ultra implementation.",true)

    local layout=tab("Layouts","panels-top-left")
    local collapsible=group(layout,"Left","Collapse & pop-out")
    self.Groups.Collapsible=collapsible
    collapsible:AddLabel("Use the header controls to collapse or detach this group.",true)
    collapsible:AddToggle("UltraLayoutValue",{Text="Value survives reparenting",Default=true})
    local actions=group(layout,"Right","Layout actions")
    actions:AddButton({Text="Toggle group collapse",Func=function() collapsible:ToggleCollapsed() end})
    actions:AddButton({Text="Toggle group pop-out",Func=function() collapsible:TogglePoppedOut() end})
    actions:AddButton({Text="Compact sidebar",Func=function() Window:SetCompact(not Window:IsSidebarCompacted()) end})
    actions:AddToggle("UltraWarning",{Text="Tab warning banner",Default=false,Callback=function(v) layout:UpdateWarningBox({Visible=v,Title="Preview warning",Text="This warning is a native tab component."}) end})
    local box=layout:AddLeftTabbox("Native tabbox")
    self.Groups.Tabbox=box
    box:AddTab("General"):AddInput("UltraTabboxA",{Text="General value",Default="Preserved"})
    box:AddTab("Advanced"):AddToggle("UltraTabboxB",{Text="Advanced option",Default=false})
    local nested=actions:AddTabbox("Nested tabbox")
    nested:AddTab("One"):AddLabel("Tabbox inside a groupbox.",true)
    nested:AddTab("Two"):AddLabel("Native nested content.",true)
    actions:AddButton({Text="Toggle tabbox pop-out",Func=function() box:TogglePoppedOut() end})

    local media=tab("Media","image")
    local visual=group(media,"Left","Image & 3D viewport")
    visual:AddImage("UltraImage",{Image="sparkles",Height=90,ScaleType=Enum.ScaleType.Fit})
    local model=Instance.new("Part");model.Name="ImperiumViewportSample";model.Size=Vector3.new(3,3,3);model.Anchored=true;model.Color=Color3.fromRGB(221,183,219)
    visual:AddViewport("UltraViewport",{Object=model,Clone=true,AutoFocus=true,Interactive=true,Height=160});model:Destroy()
    local custom=Instance.new("TextLabel");custom.Text="Native UI passthrough";custom.FontFace=Library.Scheme.Font;custom.TextSize=15
    custom.TextColor3=Library.Scheme.FontColor;custom.BackgroundTransparency=1;custom.Size=UDim2.fromScale(1,1)
    visual:AddUIPassthrough("UltraPassthrough",{Instance=custom,Height=36})
    local cards=group(media,"Right","Identity & community")
    cards:AddPlayerInfo("UltraPlayer",{Player=Library.LocalPlayer,Description="Live Roblox profile",Height=90})
    cards:AddDiscordBox("UltraCommunity",{Title="Imperium",Subtitle="Native community card",Avatar="sparkles",Accent="AccentColor",Status="online",Buttons={{Text="Test card action",Style="Secondary",Func=function() notify("Community card callback received.") end}}})
    local video=group(media,"Left","Video")
    video:AddInput("UltraVideoAsset",{Text="Roblox video asset",Default="",Placeholder="rbxassetid://…",Finished=true})
    local player=video:AddVideo("UltraVideo",{Video="",Playing=false,Looped=true,Volume=0,Height=110})
    video:AddButton({Text="Load / play asset",Func=function()
        local id=O.UltraVideoAsset.Value:match("^rbxassetid://(%d+)$") or O.UltraVideoAsset.Value:match("^(%d+)$")
        if not id then notify("Enter a Roblox video asset ID accessible to this experience.");return end
        player:SetVideo("rbxassetid://"..id);player:Play()
    end}):AddButton({Text="Pause",Func=function() player:Pause() end})
    video:AddLabel("Playback depends on asset permissions; no sample video is downloaded automatically.",true)

    local feedback=tab("Feedback","bell")
    local notices=group(feedback,"Left","Notifications & history")
    notices:AddDropdown("UltraNotifyType",{Text="Type",Values={"Info","Success","Warning","Error"},Default=1})
    notices:AddDropdown("UltraNotifySide",{Text="Notification side",Values={"Left","Right"},Default="Right",Callback=function(v) Library:SetNotifySide(v) end})
    notices:AddButton({Text="Send interactive notification",Func=function()
        Library:Notify({Title="Imperium notification",Description="The native action, close and history behavior is preserved.",Type=O.UltraNotifyType.Value,Time=8,Closable=true,Buttons={{Text="Acknowledge",Func=function() notify("Acknowledged") end}}})
    end})
    notices:AddButton({Text="Open notification history",Func=function() Library:SetNotificationHistoryVisible(true) end})
    notices:AddButton({Text="Clear notification history",Func=function() Library:ClearNotificationHistory() end})
    local progress,progressStep
    notices:AddButton({Text="Start progress",Func=function()
        if progress and not progress.Destroyed then progress:Destroy() end
        progressStep=0
        progress=Library:Notify({Title="Preview progress",Description="Use Next step to advance.",Time=30,Steps=3})
    end}):AddButton({Text="Next step",Func=function() if progress and not progress.Destroyed then progressStep=math.min(3,progressStep+1);progress:ChangeStep(progressStep) end end})
    local dialogs=group(feedback,"Right","Dialogs & loading")
    function self:OpenDialog()
        return Window:AddDialog("UltraDialog",{Title="Imperium dialog",Description="Native dialog actions, variants, delay and outside dismissal.",OutsideClickDismiss=true,FooterButtons={
            Cancel={Title="Cancel",Variant="Ghost",Order=1,Callback=function(d) d:Dismiss() end},
            Confirm={Title="Confirm",Variant="Primary",WaitTime=1,Order=2,Callback=function(d) d:Dismiss();notify("Dialog confirmed") end},
        }})
    end
    dialogs:AddButton({Text="Open dialog",Func=function() self:OpenDialog() end})
    function self:OpenLoading(errorPage)
        if Library.ActiveLoading then Library.ActiveLoading:Destroy() end
        local loading=Library:CreateLoading({Title="IMPERIUM / loading preview",TotalSteps=3,CurrentStep=1,ShowSidebar=true})
        loading:SetMessage("Component preview");loading:SetDescription("Manual progress; no game actions.")
        loading.Sidebar:AddButton({Text="Next step",Func=function() loading:SetCurrentStep(math.min(3,loading.CurrentStep+1)) end})
        loading.Sidebar:AddButton({Text="Show error state",Func=function() loading:SetErrorMessage("Preview error — test retry and close actions.");loading:ShowErrorPage(true) end})
        loading.Sidebar:AddButton({Text="Close loading preview",Func=function() loading:Destroy() end})
        loading:SetErrorButtons({Retry={Title="Retry",Variant="Primary",Callback=function(l) l:ShowErrorPage(false) end},Close={Title="Close",Variant="Secondary",Callback=function(l) l:Destroy() end}})
        if errorPage then loading:SetErrorMessage("Preview error");loading:ShowErrorPage(true) end
        return loading
    end
    dialogs:AddButton({Text="Loading / error preview",Func=function() self:OpenLoading(false) end})
    function self:OpenUnsupported()
        local child=fetch("Library.lua");own(child)
        fetch("addons/Materials.lua").new(child)
        local screen=child:CreateUnsupportedScreen({Title="Imperium / capability preview",Information={"Demonstration of the native unsupported screen.","This does not mean your current executor is unsupported."}})
        if screen then
            screen.Window:AddTab("Return","arrow-left"):AddLeftGroupbox("Preview"):AddButton({Text="Close capability preview",Func=function() child:Unload() end})
        end
        return screen,child
    end
    dialogs:AddButton({Text="Unsupported screen preview",Func=function() self:OpenUnsupported() end})
    local status=group(feedback,"Left","Status & countdown")
    local countdown=status:AddStatusLabel("UltraCountdown",{MaxHeight=110,Items={{Text="Library",Status="Ready"},{Text="Countdown",Time=os.time()+60}}})
    status:AddButton({Text="Restart countdown",Func=function() countdown:SetItems({{Text="Library",Status="Ready"},{Text="Countdown",Time=os.time()+60}}) end})
    local floats=group(feedback,"Right","Floating widgets")
    local widgets={}
    local function cleanupWidgets() for _,v in ipairs(widgets) do if v.Destroy then v:Destroy() elseif v.Button then v.Button:Destroy() end end;table.clear(widgets) end
    floats:AddButton({Text="Show draggable widgets",Func=function()
        cleanupWidgets()
        local label=Library:AddDraggableLabel({Text="Imperium floating label",Icon="sparkles"});widgets[#widgets+1]=label
        local button=Library:AddDraggableButton({Text="Floating action",Func=function() notify("Floating button activated") end});button.Button.Position=UDim2.fromOffset(350,70);widgets[#widgets+1]=button
        local icon=Library:AddDraggableImageButton({Icon="bell",Func=function() Library:ToggleNotificationHistory() end});icon.Button.Position=UDim2.fromOffset(530,70);widgets[#widgets+1]=icon
        local watermark=Library:AddWatermark({{Text="IMPERIUM",Icon="sparkles"},{PlayerCard=true},{Text="Feature preview"}});watermark.Holder.Position=UDim2.fromOffset(20,120);widgets[#widgets+1]=watermark
    end})
    floats:AddButton({Text="Remove floating widgets",Func=cleanupWidgets})
    floats:AddButton({Text="Test minimized labels",Func=function()
        Window:ClearMinimizedLabels()
        Window:SetMinimizedSubtitle("Native status labels")
        Window:AddMinimizedLabel("Session status remains available in the capsule.")
        Window:AddMinimizedLabel("SetText, SetVisible and Destroy remain native methods.")
        Window:SetMinimized(true)
    end})
    floats:AddButton({Text="Clear minimized labels",Func=function() Window:ClearMinimizedLabels();Window:SetMinimizedSubtitle("") end})

    local windowTools=group(Library.Tabs.Settings,"Left","Native window options")
    windowTools:AddToggle("UltraAlwaysOnTop",{Text="Always on top",Default=Window.AlwaysOnTop,Callback=function(v) Window:SetAlwaysOnTop(v) end})
    windowTools:AddToggle("UltraSnap",{Text="Snap to screen edges",Default=false,Callback=function(v) Window:SetSnapping(v) end})
    windowTools:AddToggle("UltraGlow",{Text="Optional native glow",Default=false,Callback=function(v) Window:SetGlow(v) end})
    windowTools:AddToggle("UltraCursor",{Text="Native custom cursor",Default=false,Callback=function(v) Library.ShowCustomCursor=v end})
    windowTools:AddToggle("PrimeRadiusHierarchy",{Text="Use Imperium radius hierarchy",Default=true,Callback=function(v)
        if Library.PrimeMaterial then Library.PrimeMaterial:SetRadiusHierarchy(v) end
        if O.UltraCorners then O.UltraCorners:SetDisabled(v) end
    end})
    windowTools:AddSlider("UltraCorners",{Text="Custom corner radius",Min=0,Max=24,Default=16,Rounding=0,Disabled=true,Tooltip="Turn off Imperium radius hierarchy to use the native radius control.",Callback=function(v) Window:SetCornerRadius(v) end})
    windowTools:AddSlider("UltraScale",{Text="UI scale",Min=75,Max=200,Default=100,Rounding=0,Suffix="%",Callback=function(v) Library:SetDPIScale(v) end})
    windowTools:AddButton({Text="Reset layout",Func=function() Library:ResetLayout() end})
    windowTools:AddButton({Text="Test rich footer",Func=function() Window:SetFooter({{Text="IMPERIUM"},{Text="ObsidianPrime",Copyable=true,CopyText="ObsidianPrime"}}) end})

    local key=Window:AddKeyTab("Key access")
    self.Tabs["Key access"]=key
    key:AddLabel("Local key UI demonstration. Enter IMPERIUM.",true)
    key:AddKeyBox(function(value) notify(value=="IMPERIUM" and "Key accepted" or "Key did not match") end)

    local profiles=tab("Profiles","folder-cog")
    local Theme=fetch("addons/ThemeManager.lua")
    local Save=fetch("addons/SaveManager.lua")
    self.ThemeManager,self.SaveManager=Theme,Save
    Theme:SetLibrary(Library);Theme:SetFolder("ObsidianPrime/PreviewProfiles")
    Save:SetLibrary(Library);Save:SetFolder("ObsidianPrime/PreviewProfiles");Save:SetSubFolder("Workbench")
    Save:SetLoadingOrder(true,{"Input","Slider","Dropdown","PriorityDropdown","ColorPicker","KeyPicker","Toggle"})
    Save:IgnoreThemeSettings()
    Theme:ApplyToTab(profiles)
    Save:BuildConfigSection(profiles)
    -- Full native config tools remain available, but startup never loads a profile automatically.
    local utilities=group(profiles,"Left","Preview profile actions")
    utilities:AddButton({Text="Load configured autoload profile",Func=function() Save:LoadAutoloadConfig() end})
    utilities:AddButton({Text="Restore Imperium theme",Func=function() Theme:ApplyTheme("Imperium") end})
    utilities:AddLabel("Profiles are isolated under ObsidianPrime/PreviewProfiles. Theme and config import/export use the native managers.",true)
    Library:OnUnload(function()
        self.Alive=false;cleanupWidgets()
        if Library.ActiveLoading then Library.ActiveLoading:Destroy() end
        for _,object in ipairs(self.Owned) do if object.Unload then object:Unload() elseif object.Destroy then object:Destroy() end end
    end)
    return self
end
return Showcase
