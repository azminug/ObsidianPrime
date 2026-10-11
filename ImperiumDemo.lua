-- Imperium Frosted 0.12. Local preview; no gameplay remotes or automation.
local env = (getgenv and getgenv()) or _G
local OWNER = "ObsidianPrimeDemo"
local function fetch(path)
    local chunk, err = loadstring(readfile("ObsidianPrime/" .. path), "@ObsidianPrime/" .. path)
    assert(chunk, err)
    return chunk()
end
if env[OWNER] then env[OWNER]:Unload() end
local Library = fetch("Library.lua")
env[OWNER] = Library
local alive, connections = true, {}
Library:OnUnload(function()
    alive = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    if Library.PrimeMotion then Library.PrimeMotion:Destroy() end
    if env[OWNER] == Library then env[OWNER] = nil end
end)
local ok, err = xpcall(function()
    Library.PrimeMotion = fetch("addons/Motion.lua").new()
    local viewport = workspace.CurrentCamera.ViewportSize
    local Window = Library:CreateWindow({
        Title = "IMPERIUM", Footer = "", Icon = "sparkles", CopyableFooter = false,
        Size = UDim2.fromOffset(math.min(940,viewport.X-56), math.min(650,viewport.Y-145)),
        Center = true, AutoShow = true, ShowCustomCursor = false, Resizable = true,
        CornerRadius = 16, ToggleKeybind = Enum.KeyCode.U, Glow = false, GroupFade = true,
        TabSwipeFrom = "bottom", TabSwipeOffset = 12,
        Animations = {TabSwitch=true,ToggleWindow=false,Groupbox=false,GroupboxCollapse=true,Dropdown=true,KeyPicker=true,SubTabUnderline=true,SidebarSubTabs=true},
    })
    local Prime = fetch("addons/Imperium.lua").new(Library,Window)
    local Appearance = fetch("addons/Cosmic.lua").new(Library,Window)
    Prime.Appearance = Appearance
    Appearance.Acrylic = fetch("addons/Acrylic.lua").new(Library,Window)
    local Materials = fetch("addons/Materials.lua").new(Library)
    local Options,Toggles=Library.Options,Library.Toggles
    local Players=game:GetService("Players")
    local Stats=game:GetService("Stats")
    local Home=Prime:AddTab("Overview","layout-dashboard")
    local Fishing=Prime:AddTab("Fishing","fish")
    local Settings=Prime:AddTab("Settings","settings")
    local function group(tab,side,name)
        return tab:AddGroupbox({Name=name,Side=side,DisableCollapsing=true,PopOut=false})
    end
    local function notify(title,message)
        Library:Notify({Title=title,Description=message,Time=4,Type="Info"})
    end
    local Live=group(Home,"Left","Live session")
    local Metrics=Live:AddStatGrid("PrimeMetrics",{Columns=3,TileHeight=64,Items={
        {Text="FPS",Value="--"},{Text="ping ms",Value="--"},{Text="players",Value=tostring(#Players:GetPlayers())},
    }})
    local Session=Live:AddLabel("Session 00:00",true)
    local Activity=group(Home,"Right","Session activity")
    local ActivityText=Activity:AddLabel("Connected. Waiting for session events.",true)
    local entries={}
    local function record(message,category)
        local filter=Library.Options.PrimeFilter
        if filter and category and not filter.Value[category] then return end
        table.insert(entries,1,os.date("%H:%M:%S") .. "  " .. message)
        while #entries>8 do table.remove(entries) end
        ActivityText:SetText(table.concat(entries,"\n\n"))
    end
    connections[#connections+1]=Players.PlayerAdded:Connect(function(player) record(player.DisplayName .. " joined","Session events") end)
    connections[#connections+1]=Players.PlayerRemoving:Connect(function(player) record(player.DisplayName .. " left","Session events") end)
    local Shortcuts=group(Home,"Left","Quick actions")
    Shortcuts:AddButton({Text="Open Fishing",Func=function() Fishing:Show() end})
    Shortcuts:AddButton({Text="Notification history",Func=function() Library:ToggleNotificationHistory() end})
    Shortcuts:AddButton({Text="Minimize to capsule",Func=function() Window:ToggleMinimized() end})
    Live:AddLabel(Players.LocalPlayer.DisplayName,true)
    local Controls=group(Fishing,"Left","Fishing controls")
    Controls:AddToggle("PrimePreview",{Text="Enable control preview",Default=false})
    Controls:AddSlider("PrimeIntensity",{Text="Intensity",Default=56,Min=0,Max=100,Rounding=0,Suffix="%",HideMax=true,AllowRightClickInput=true})
    Controls:AddInput("PrimeMessage",{Text="Notification message",Default="",Placeholder="Type a messageâ€¦",Finished=false})
    Controls:AddDropdown("PrimeType",{Text="Notification type",Values={"Info","Success","Warning"},Default=1,Expandable=false})
    Controls:AddButton({Text="Send notification",Func=function()
        Library:Notify({Title="Imperium",Description=Options.PrimeMessage.Value~="" and Options.PrimeMessage.Value or "Preview ready",Type=Options.PrimeType.Value,Time=4})
        record("Notification preview sent","Notifications")
    end})
    Controls:AddDivider("Filters")
    Controls:AddDropdown("PrimeFilter",{Text="Show in activity",Values={"Session events","Notifications"},Multi=true,Default={"Session events","Notifications"},Expandable=false})
    Controls:AddLabel("Configuration preview only.",true)
    local GameStats=group(Fishing,"Right","Live game statistics")
    local FishMetrics=GameStats:AddStatGrid("PrimeFishMetrics",{Columns=2,TileHeight=70,Items={
        {Text="FPS",Value="--"},{Text="ping ms",Value="--"},{Text="frame ms",Value="--"},{Text="players",Value="--"},
    }})
    local Timing=GameStats:AddLabel("Session 00:00",true)
    local ControlStatus=GameStats:AddStatusLabel("PrimeControlStatus",{Items={{Text="Control preview",Status="Off"}}})
    Toggles.PrimePreview:OnChanged(function()
        ControlStatus:SetItems({{Text="Control preview",Status=Toggles.PrimePreview.Value and "On" or "Off"}})
    end)
    local PingStatus=GameStats:AddLabel("Reading network latencyâ€¦",true)
    GameStats:AddButton({Text="Reset session timer",Func=function() env.PrimeSessionStart=os.clock();record("Session timer reset") end})
    local Material=group(Settings,"Left","Material & motion")
    Material:AddToggle("PrimeOpaque",{Text="Readable / opaque mode",Default=false,Callback=function(value) Appearance:SetOpaque(value) end})
    Material:AddToggle("PrimeFrost",{Text="Blur world while menu is open",Default=true,Callback=function(value) Appearance.FrostEnabled=value;Appearance.Acrylic:SetEnabled(value and not Toggles.PrimeOpaque.Value) end})
    Material:AddToggle("PrimeReducedMotion",{Text="Reduce motion",Default=false,Callback=function(value) Prime:SetReducedMotion(value) end})
    Material:AddToggle("PrimeSmoothDrag",{Text="Spring window drag",Default=true,Callback=function(value) Library.SmoothDrag=value end})
    Material:AddLabel("Blur affects the 3D scene while the menu is open. Game HUD is a separate layer. Opaque mode improves contrast.",true)
    local Layout=group(Settings,"Right","Window & accessibility")
    Layout:AddLabel("Menu key"):AddKeyPicker("PrimeMenuKey",{Default="U",Mode="Toggle",NoUI=true,Text="Menu"})
    Library.ToggleKeybind=Options.PrimeMenuKey
    Layout:AddButton({Text="Center window",Func=function() Appearance:CenterWindow() end})
    Layout:AddDropdown("PrimeDockLocation",{Text="Capsule starting position",Values={"Top left","Top right","Bottom left","Bottom right"},Default="Top left",Callback=function(value) Appearance:SetDockPosition(value) end})
    Layout:AddButton({Text="Move window left",Func=function() Appearance:MoveWindow(-40,0) end})
    Layout:AddButton({Text="Move window right",Func=function() Appearance:MoveWindow(40,0) end})
    Layout:AddButton({Text="Move window up",Func=function() Appearance:MoveWindow(0,-40) end})
    Layout:AddButton({Text="Move window down",Func=function() Appearance:MoveWindow(0,40) end})
    Layout:AddLabel("Drag capsule to move; click to minimize/restore. Tab: focus Â· Enter: activate Â· Escape: release Â· Ctrl+M: minimize.",true)
    Layout:AddButton({Text="Unload preview",Func=function() Library:Unload() end})
    local Showcase = fetch("addons/Showcase.lua").build(Library,Window,fetch,Appearance)
    Appearance:FinishBuild()
    local rect=Window.MainFrame
    Window:SetSizePosition(nil,UDim2.fromOffset(math.max(16,(viewport.X-rect.Size.X.Offset)/2),58))
    Appearance:SetDockPosition("Top left")
    Appearance.Dock.Position=UDim2.fromOffset(20,4)
    local elapsed,frames,cache=0,0,{}
    env.PrimeSessionStart=os.clock()
    local function value(grid,key,text,prefix)
        local id=prefix..key
        if cache[id]~=text then cache[id]=text;grid:SetValue(key,text) end
    end
    connections[#connections+1]=game:GetService("RunService").RenderStepped:Connect(function(dt)
        if not alive then return end
        elapsed=elapsed+dt;frames=frames+1
        if elapsed<1 then return end
        local fps=string.format("%.0f",frames/elapsed)
        local ms=string.format("%.1f",elapsed/frames*1000)
        local success,ping=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        local pingText=success and string.format("%.0f",ping) or "--"
        local count=tostring(#Players:GetPlayers())
        value(Metrics,1,fps,"home");value(Metrics,2,pingText,"home");value(Metrics,3,count,"home")
        value(FishMetrics,1,fps,"fish");value(FishMetrics,2,pingText,"fish");value(FishMetrics,3,ms,"fish");value(FishMetrics,4,count,"fish")
        local t=math.floor(os.clock()-env.PrimeSessionStart)
        local text=string.format("Session %02d:%02d",math.floor(t/60),t%60)
        Session:SetText(text);Timing:SetText(text)
        local network=success and "Latency is read from Roblox network statistics." or "Latency unavailable on this client."
        if cache.network~=network then cache.network=network;PingStatus:SetText(network) end
        Appearance:SetTelemetry(fps,pingText)
        elapsed,frames=0,0
    end)
    record("Preview loaded; telemetry connected")
    Library.PrimePreview={Appearance=Appearance,Materials=Materials,Showcase=Showcase,Tabs={Home=Home,Fishing=Fishing,Settings=Settings}}
    print("[Imperium Frosted 0.12] READY",Window.MainFrame.AbsoluteSize,"PID target set by Potassium")
end,function(message) return debug.traceback(tostring(message),2) end)
if not ok then pcall(function() Library:Unload() end);error("[Imperium Frosted] "..tostring(err),0) end
