-- Cosmic glass presentation for ObsidianPrime. Native Roblox UI; optional camera-local Acrylic module.
-- Transparency is deliberately bounded; opaque mode is available at all times.
local Cosmic = {}

function Cosmic.new(Library, Window)
    local TweenService = game:GetService("TweenService")
    local Spring = Library.PrimeMotion
    Library.PrimeSelectionEnabled = true
    local Input = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    local main, mini = Window.MainFrame, Window.MiniFrame
    assert(main and mini, "Cosmic requires a minimizable ObsidianPrime window")
    local self = { Alive = true, ReducedMotion = false, Opaque = false, Shadow = "None",
        Minimized = Window:IsMinimized(), Status = "Ready", Generation = 0 }
    local connections, owned, tweens, shadows = {}, {}, {}, {}
    local old = { Minimize = Window.SetMinimized, ToggleMinimized = Window.ToggleMinimized,
        IsMinimized = Window.IsMinimized, Toggle = Window.Toggle, Subtitle = Window.SetMinimizedSubtitle }
    local savedPosition, savedAnchor = main.Position, main.AnchorPoint
    local scale = main:FindFirstChildOfClass("UIScale")
    local groupFade = main:IsA("CanvasGroup")
    local restingScale = scale and scale.Scale or 1
    local function create(class, properties, parent)
        local object = Instance.new(class)
        for key, value in pairs(properties) do object[key] = value end
        object.Parent = parent
        owned[#owned + 1] = object
        return object
    end
    local function bind(signal, callback)
        local connection = signal:Connect(callback)
        connections[#connections + 1] = connection
        return connection
    end
    local function animate(object, properties, duration)
        if tweens[object] then tweens[object]:Cancel(); tweens[object] = nil end
        if self.ReducedMotion or duration == 0 then
            for key, value in pairs(properties) do object[key] = value end
        elseif Spring then
            Spring:To(object, properties, 26, 0.83)
        else
            local tween = TweenService:Create(object, TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
            tweens[object] = tween
            tween:Play()
        end
    end
    local gradient = create("UIGradient", { Rotation = 100,
        Color = ColorSequence.new(Color3.fromRGB(255, 248, 255), Color3.fromRGB(217, 210, 232)),
        Transparency = NumberSequence.new(0),
    }, main)
    local rim = create("UIStroke", { Name = "CosmicRim", ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Library.Scheme.FontColor, Thickness = 1, Transparency = 0.24 }, main)
    Library.Registry[rim] = {Color="FontColor"}
    create("UIGradient", { Rotation = 115, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.5, 0.72), NumberSequenceKeypoint.new(1, 0.2),
    }) }, rim)

    local dock = create("TextButton", { Name = "Open Imperium menu", Text = "", AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(35, 33, 44), BackgroundTransparency = 0.25,
        BorderSizePixel = 0, Size = UDim2.fromOffset(256, 38), Position = UDim2.fromOffset(20, 20),
        ZIndex = 30, Selectable = true }, main.Parent)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, dock)
    self.Dock = dock
    local dockStroke = create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(151, 140, 164), Thickness = 1 }, dock)
    local dockScale = create("UIScale", { Scale = 1 }, dock)
    local sourceLogo=main:FindFirstChild("PrimeLogo",true)
    local dockLogo=create("ImageLabel",{Name="ImperiumCapsuleLogo",BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,7),Size=UDim2.fromOffset(24,24),ZIndex=31},dock)
    if sourceLogo and sourceLogo:IsA("ImageLabel") then
        for _,property in ipairs({"Image","ImageRectOffset","ImageRectSize","ImageColor3"}) do dockLogo[property]=sourceLogo[property] end
        create("UICorner",{CornerRadius=UDim.new(0,6)},dockLogo)
    else
        local icon=Library:GetCustomIcon("sparkles")
        if icon then Library:ApplyLucideIcon(dockLogo,icon) end
    end
    local waveform=create("Frame",{Name="ImperiumHeartbeat",BackgroundTransparency=1,
        Position=UDim2.fromOffset(50,9),Size=UDim2.fromOffset(38,20),ZIndex=31},dock)
    local waveSegments={}
    for index=1,7 do
        local line=create("Frame",{Name="PulseSegment"..index,AnchorPoint=Vector2.new(.5,.5),
            BorderSizePixel=0,BackgroundColor3=Library.Scheme.AccentColor,ZIndex=31},waveform)
        create("UICorner",{CornerRadius=UDim.new(1,0)},line)
        Library.Registry[line]={BackgroundColor3="AccentColor"}
        waveSegments[index]=line
    end
    local pulseTimer,pulseGeneration=nil,0
    local random=Random.new()
    local function wave(amplitude,duration)
        local points={{0,10},{8,10},{12,10-amplitude*.25},{16,10+amplitude},
            {21,10-amplitude},{25,10+amplitude*.3},{29,10},{38,10}}
        for index,line in ipairs(waveSegments) do
            local a,b=points[index],points[index+1]
            local dx,dy=b[1]-a[1],b[2]-a[2]
            animate(line,{Position=UDim2.fromOffset((a[1]+b[1])/2,(a[2]+b[2])/2),
                Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),1.5),Rotation=math.deg(math.atan2(dy,dx)),
                BackgroundTransparency=amplitude>4 and .12 or .32},duration)
        end
    end
    local function stopPulse()
        pulseGeneration=pulseGeneration+1
        if pulseTimer then task.cancel(pulseTimer);pulseTimer=nil end
        for _,line in ipairs(waveSegments) do
            if Spring then Spring:Cancel(line) end
            if tweens[line] then tweens[line]:Cancel();tweens[line]=nil end
        end
        wave(3,0)
    end
    wave(3,0)
    local status = create("TextLabel", {Name="PrimeValue", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(104, 0), Size = UDim2.new(1, -116, 1, 0),
        Text = "-- FPS · -- ms", FontFace = Library.Scheme.Font, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Library.Scheme.FontColor, ZIndex = 31 }, dock)
    local hint = create("TextLabel", {Name="ImperiumCapsuleTooltip", BackgroundColor3 = Color3.fromRGB(35, 33, 44), BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 6), Size = UDim2.fromOffset(256, 28), Text = "Open menu · Ctrl+M",
        FontFace = Library.Scheme.Font, TextSize = 13, TextColor3 = Library.Scheme.FontColor, Visible = false, ZIndex = 32 }, dock)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, hint)
    for _,label in ipairs({status,hint}) do
        Library.Registry[label]={FontFace=function() return Font.new(Library.Scheme.Font.Family,Enum.FontWeight.Regular,Library.Scheme.Font.Style) end,
            TextColor3="FontColor"}
        label.FontFace=Library.Registry[label].FontFace()
    end
    self.DockLogo,self.Waveform,self.TelemetryLabel,self.Hint=dockLogo,waveform,status,hint
    local details
    if Window.MinimizedBody then
        details=create("Frame",{Name="ImperiumCapsuleDetails",BackgroundColor3=Library.Scheme.MainColor,
            BackgroundTransparency=.2,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,
            Position=UDim2.new(0,0,1,6),Size=UDim2.fromOffset(320,0),Visible=false,ZIndex=32},dock)
        create("UICorner",{CornerRadius=UDim.new(0,12)},details)
        create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},details)
        Window.MinimizedBody.Parent=details
        if Window.MinimizedSubtitleLabel then
            local subtitle=Window.MinimizedSubtitleLabel
            subtitle.Parent=details;subtitle.LayoutOrder=0;subtitle.Size=UDim2.new(1,-24,0,24);subtitle.TextTransparency=.05
        end
        self.Details=details
    end
    local function hover(value,mouse)
        hint.Visible = value and mouse==true and Input.MouseEnabled and Input.KeyboardEnabled and Library.Toggled and not (details and details.Visible)
        animate(dockScale, { Scale = value and 1.025 or 1 }, 0.16)
        animate(dockStroke, { Color = value and Color3.fromRGB(221, 183, 219) or Color3.fromRGB(151, 140, 164) }, 0.16)
    end
    bind(dock.MouseEnter, function() hover(true,true) end)
    bind(dock.MouseLeave, function() hover(false) end)
    bind(dock.SelectionGained, function() hover(true) end)
    bind(dock.SelectionLost, function() hover(false) end)

    -- Feathered slices approximate the supplied shadow recipes, scaled for a dark surface.
    local function shadowFor(frame)
        local layers = {}
        for index = 1, 2 do
            layers[index] = create("ImageLabel", { Name = "CosmicShadow", BackgroundTransparency = 1, Active = false,
                Image = "rbxassetid://6014261993", ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
                ImageColor3 = index == 1 and Color3.fromRGB(196, 172, 221) or Color3.fromRGB(8, 6, 15),
                ZIndex = frame == dock and 29 or 0 }, frame.Parent)
        end
        local function sync()
            local radius = self.Shadow == "Raised" and 22 or 36
            local offset = self.Shadow == "Raised" and 6 or 12
            for index, image in ipairs(layers) do
                local direction = index == 1 and -1 or 1
                image.Visible = self.Alive and frame.Visible and (self.Shadow == "Raised" or self.Shadow == "Soft")
                image.Position = UDim2.fromOffset(frame.AbsolutePosition.X - radius + offset * direction, frame.AbsolutePosition.Y - radius + offset * direction)
                image.Size = UDim2.fromOffset(frame.AbsoluteSize.X + radius * 2, frame.AbsoluteSize.Y + radius * 2)
                image.SliceScale = radius / 49
                image.ImageTransparency = index == 1 and 0.9 or (self.Shadow == "Raised" and 0.38 or 0.24)
            end
        end
        for _, property in ipairs({ "AbsolutePosition", "AbsoluteSize", "Visible" }) do bind(frame:GetPropertyChangedSignal(property), sync) end
        shadows[#shadows + 1] = sync
        sync()
    end
    shadowFor(main)
    shadowFor(dock)
    local inset = create("UIStroke", { Name = "CosmicInset", ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(183, 164, 205), Thickness = 3, Transparency = 0.65, Enabled = false }, main)
    create("UIGradient", { Rotation = 125, Color = ColorSequence.new(Color3.fromRGB(15, 10, 24), Color3.fromRGB(235, 214, 255)) }, inset)

    local function syncShell()
        if not self.Alive then return end
        mini.Visible = false
        dock.Visible = Library.Toggled
        if details then details.Visible=Library.Toggled and self.Minimized and (Window.MinimizedBody.Visible or self.ExplicitSubtitle==true) end
        hint.Visible = false
        if not dock.Visible then stopPulse() end
    end
    bind(mini:GetPropertyChangedSignal("Visible"), syncShell)
    bind(main:GetPropertyChangedSignal("Visible"), syncShell)
    if Window.MinimizedBody then bind(Window.MinimizedBody:GetPropertyChangedSignal("Visible"),syncShell) end
    Window.IsMinimized = function() return self.Minimized end
    Window.Cosmic = self
    local function finish(value, generation)
        if not self.Alive or generation ~= self.Generation then return end
        if Spring then Spring:Cancel(main); if scale then Spring:Cancel(scale) end end
        old.Minimize(Window, value)
        main.Position, main.AnchorPoint = savedPosition, savedAnchor
        if scale then scale.Scale = restingScale end
        if groupFade then main.GroupTransparency = 0 end
        self.Transition = false
        syncShell()
    end
    Window.SetMinimized = function(_, value)
        if not self.Alive then return end
        if value == nil then value = not self.Minimized end
        value = value == true
        if value == self.Minimized and not self.Transition then return end
        local wasTransition = self.Transition
        self.Generation = self.Generation + 1
        local generation = self.Generation
        if tweens[main] then tweens[main]:Cancel() end
        if scale and tweens[scale] then tweens[scale]:Cancel() end
        if Spring then Spring:Cancel(main); if scale then Spring:Cancel(scale) end end
        if not self.Minimized and not wasTransition then
            savedPosition, savedAnchor = main.Position, main.AnchorPoint
            restingScale = scale and scale.Scale or 1
        end
        self.Minimized, self.Transition = value, true
        syncShell()
        if self.ReducedMotion or not Library.Toggled then finish(value, generation); return end
        if value then
            if groupFade then animate(main, {GroupTransparency=1}, 0.18) end
            animate(main, { Position = savedPosition + UDim2.fromOffset(0, 16) }, 0.18)
            if scale then animate(scale, { Scale = restingScale * 0.94 }, 0.18) end
        else
            old.Minimize(Window, false)
            if groupFade then main.GroupTransparency=1;animate(main,{GroupTransparency=0},0.2) end
            main.Position, main.AnchorPoint = savedPosition + UDim2.fromOffset(0, 16), savedAnchor
            if scale then scale.Scale = restingScale * 0.94; animate(scale, { Scale = restingScale }, 0.2) end
            animate(main, { Position = savedPosition }, 0.2)
        end
        task.delay(0.38, function() finish(value, generation) end)
    end
    Window.ToggleMinimized = function() Window:SetMinimized(not self.Minimized) end
    Window.Toggle = function(_, value)
        if self.Transition then
            self.Generation = self.Generation + 1
            if tweens[main] then tweens[main]:Cancel() end
            if scale and tweens[scale] then tweens[scale]:Cancel() end
            finish(self.Minimized, self.Generation)
        end
        old.Toggle(Window, value)
        syncShell()
    end
    Window.SetMinimizedSubtitle = function(_, text)
        old.Subtitle(Window, text)
        self.Status = text and text ~= "" and text or "Ready"
        self.ExplicitSubtitle=text~=nil and text~=""
        syncShell()
        hint.Text = "Open menu · Ctrl+M"
    end
    local dragInput, dragStart, dragPosition, dragged, suppressUntil = nil, nil, nil, false, 0
    bind(dock.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if Spring then Spring:Cancel(dock) end
        dragInput, dragStart, dragPosition, dragged = input, input.Position, dock.Position, false
        hover(false)
    end)
    bind(Input.InputChanged, function(input)
        if not dragInput then return end
        local touch = dragInput.UserInputType == Enum.UserInputType.Touch
        if (touch and input ~= dragInput) or (not touch and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then dragged = true end
        if not dragged then return end
        hint.Visible = false
        local target = dragPosition + UDim2.fromOffset(delta.X, delta.Y)
        local viewport = workspace.CurrentCamera.ViewportSize
        local x = target.X.Scale * viewport.X + target.X.Offset - dock.AnchorPoint.X * dock.AbsoluteSize.X
        local y = target.Y.Scale * viewport.Y + target.Y.Offset - dock.AnchorPoint.Y * dock.AbsoluteSize.Y
        x = math.clamp(x, 8, math.max(8, viewport.X - dock.AbsoluteSize.X - 8))
        y = math.clamp(y, 8, math.max(8, viewport.Y - dock.AbsoluteSize.Y - 52))
        target = UDim2.fromOffset(x + dock.AnchorPoint.X*dock.AbsoluteSize.X, y + dock.AnchorPoint.Y*dock.AbsoluteSize.Y)
        if Spring and not self.ReducedMotion then Spring:To(dock, { Position = target }, 38, 0.9) else dock.Position = target end
    end)
    bind(Input.InputEnded, function(input)
        if input ~= dragInput then return end
        if dragged then suppressUntil = os.clock() + 0.2 end
        dragInput = nil
    end)
    connections[#connections + 1] = Library:OnActivate(dock, function()
        if dragged or os.clock() < suppressUntil then dragged = false; return end
        hint.Visible=false
        Window:SetMinimized(false)
    end)
    function self:SetTelemetry(fps, ping)
        local value = string.format("%s FPS · %s ms", tostring(fps), tostring(ping))
        if status.Text ~= value then status.Text = value end
        -- A bounded beat on each real telemetry update, never an independent cosmetic loop.
        if not self.Alive or self.ReducedMotion or not dock.Visible then return end
        if pulseTimer then task.cancel(pulseTimer);pulseTimer=nil end
        pulseGeneration=pulseGeneration+1
        local generation=pulseGeneration
        wave(random:NextNumber(5.5,8.5),.16)
        pulseTimer=task.delay(random:NextNumber(.17,.25),function()
            pulseTimer=nil
            if self.Alive and generation==pulseGeneration and dock.Visible and not self.ReducedMotion then wave(3,.35) end
        end)
    end

    function self:SetOpaque(value)
        self.Opaque = value == true
        -- Frosted material is opt-in; opaque mode is the contrast reference.
        main.BackgroundTransparency = self.Opaque and 0 or 0.48
        gradient.Enabled = not self.Opaque
        dock.BackgroundTransparency = self.Opaque and 0 or 0.25
        if self.Acrylic then self.Acrylic:SetEnabled(not self.Opaque and self.FrostEnabled ~= false) end
        if Library.PrimeMaterial then Library.PrimeMaterial:SetOpaque(self.Opaque) end
        if details then details.BackgroundTransparency=self.Opaque and 0 or .2 end
        if self.Surfaces then
            for object, alpha in pairs(self.Surfaces) do
                if object.Parent then object.BackgroundTransparency = self.Opaque and 0 or alpha end
            end
        end
    end

    function self:FinishBuild()
        self.Surfaces = {}
        if not Library.PrimeMaterial then
        main.BackgroundColor3 = Color3.fromRGB(55,51,67)
        if Library.Registry[main] then Library.Registry[main].BackgroundColor3 = nil end
        for _, object in ipairs(main:GetDescendants()) do
            local registry = Library.Registry[object]
            if object:IsA("UIStroke") and registry then
                if registry.Color == "DarkColor" then object.Enabled = false
                elseif registry.Color == "OutlineColor" and object.Transparency < 1 then object.Transparency = 0.6 end
            elseif object:IsA("GuiObject") then
                if object.Name == "PrimeHeader" then
                    self.Surfaces[object] = 0.35
                    object.BackgroundColor3 = Color3.fromRGB(76,70,92)
                elseif object.Name == "PrimeSidebar" then
                    self.Surfaces[object] = 0.65
                elseif object.Name == "PrimeGroupedSurface" then
                    self.Surfaces[object] = 0.36
                    object.BackgroundColor3 = Color3.fromRGB(76,70,92)
                    if registry then registry.BackgroundColor3 = nil end
                elseif (object:IsA("TextBox") or Library.ActivationHandlers[object]) and object.BackgroundTransparency < 0.95 then
                    self.Surfaces[object] = 0.7
                end
                if object:IsA("TextLabel") and registry and registry.TextColor3 == "AccentColor" then
                    object.TextColor3=Library.Scheme.FontColor
                    registry.TextColor3="FontColor"
                end
            end
        end
        end
        -- Specular highlights are local to the hovered control, never a perpetual effect.
        for button in pairs(Library.ActivationHandlers) do
            if not Library.PrimeMaterial and button:IsDescendantOf(main) and button:IsA("GuiButton") then
            local glow = create("Frame", {Name="SpecularHover", Active=false, BackgroundColor3=Color3.new(1,1,1),
                BackgroundTransparency=1, Size=UDim2.fromScale(1,1), ZIndex=button.ZIndex }, button)
            create("UICorner", {CornerRadius=UDim.new(0,8)}, glow)
            local light = create("UIGradient", {Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.5,0.55), NumberSequenceKeypoint.new(1,1)
            })}, glow)
            bind(button.MouseMoved, function(x)
                light.Offset=Vector2.new(math.clamp((x-button.AbsolutePosition.X)/math.max(1,button.AbsoluteSize.X)-0.5,-0.5,0.5),0)
            end)
            bind(button.MouseEnter, function() if button.Active then animate(glow,{BackgroundTransparency=0.84},0.12) end end)
            bind(button.MouseLeave, function() animate(glow,{BackgroundTransparency=1},0.12) end)
            bind(button.InputBegan, function(input)
                if button.Active and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
                    animate(glow,{BackgroundTransparency=0.74},0.10)
                end
            end)
            bind(button.InputEnded, function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then animate(glow,{BackgroundTransparency=0.88},0.18) end
            end)
        end
        end
        -- One sliding selection capsule spans the sidebar, not duplicated navigation.
        local first = Library.Tabs[1]
        if not first then for _,tab in pairs(Library.Tabs) do first=tab;break end end
        if first and first.Button then
            local sidebar=main:FindFirstChild("PrimeSidebar",true)
            local host=create("Frame",{Name="ImperiumNavigationClip",BackgroundTransparency=1,
                BorderSizePixel=0,ClipsDescendants=true,Active=false,ZIndex=0},main)
            local selection=create("Frame", {Name="CosmicSelection", BackgroundColor3=Color3.fromRGB(145,128,159),
                BackgroundTransparency=0.38, BorderSizePixel=0, ZIndex=0, Active=false}, host)
            create("UICorner", {CornerRadius=UDim.new(0,10)},selection)
            create("UIStroke", {Color=Color3.fromRGB(236,223,246),Transparency=0.65,Thickness=1},selection)
            local function follow()
                local tab=Library.ActiveTab
                if not tab or not tab.Button then selection.Visible=false;return end
                local button=tab.Button
                if sidebar then
                    local origin=(sidebar.AbsolutePosition-main.AbsolutePosition)/Library.DPIScale
                    host.Position=UDim2.fromOffset(origin.X,origin.Y)
                    host.Size=UDim2.fromOffset(sidebar.AbsoluteSize.X/Library.DPIScale,sidebar.AbsoluteSize.Y/Library.DPIScale)
                else host.Size=UDim2.fromScale(1,1) end
                selection.Visible=true
                local p=(button.AbsolutePosition-host.AbsolutePosition)/Library.DPIScale
                local canvas=host:IsA("ScrollingFrame") and host.CanvasPosition or Vector2.zero
                animate(selection,{Position=UDim2.fromOffset(p.X+canvas.X,p.Y+canvas.Y),Size=UDim2.fromOffset(button.AbsoluteSize.X/Library.DPIScale,button.AbsoluteSize.Y/Library.DPIScale)},0.22)
            end
            if sidebar then
                bind(sidebar:GetPropertyChangedSignal("AbsoluteSize"),follow)
                bind(sidebar:GetPropertyChangedSignal("CanvasPosition"),follow)
            end
            for _,tab in pairs(Library.Tabs) do
                if tab.Button then
                    local show=tab.Show
                    tab.Show=function(t,...) local result=show(t,...);follow();return result end
                    bind(tab.Button:GetPropertyChangedSignal("AbsoluteSize"),follow)
                    bind(tab.Button:GetPropertyChangedSignal("AbsolutePosition"),follow)
                end
            end
            task.defer(follow)
        end
        self:SetOpaque(self.Opaque)
        self:CenterWindow()
        if scale and not self.ReducedMotion then
            if groupFade then main.GroupTransparency=1;animate(main,{GroupTransparency=0},0.24) end
            restingScale=scale.Scale
            scale.Scale=restingScale*0.94
            animate(scale,{Scale=restingScale},0.24)
            main.BackgroundTransparency=0.8
            animate(main,{BackgroundTransparency=self.Opaque and 0 or 0.48},0.24)
        end
    end
    function self:SetShadow(value)
        assert(value == "None" or value == "Raised" or value == "Soft" or value == "Inset", "Unknown shadow")
        self.Shadow = value
        inset.Enabled = value == "Inset"
        for _, sync in ipairs(shadows) do sync() end
    end
    function self:SetReducedMotion(value)
        self.ReducedMotion = value == true
        if Spring then Spring:SetReduced(self.ReducedMotion) end
        Library.ReducedMotion = self.ReducedMotion
        if self.ReducedMotion then
            stopPulse()
            self.Generation = self.Generation + 1
            for object, tween in pairs(tweens) do tween:Cancel(); tweens[object] = nil end
            dockScale.Scale = 1
            if self.Transition then finish(self.Minimized, self.Generation) end
        end
    end
    function self:CenterWindow()
        if self.Transition then return end
        local size = main.AbsoluteSize
        Window:SetSizePosition(nil, UDim2.new(0.5, -size.X / 2, 0.5, -size.Y / 2))
        savedPosition, savedAnchor = main.Position, main.AnchorPoint
    end
    function self:MoveWindow(dx, dy)
        if self.Transition then return end
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or main.Parent.AbsoluteSize
        local point, size = main.AbsolutePosition, main.AbsoluteSize
        local x = math.clamp(point.X + dx, 8, math.max(8, viewport.X - size.X - 8))
        local y = math.clamp(point.Y + dy, 8, math.max(8, viewport.Y - size.Y - 8))
        Window:SetSizePosition(nil, main.Position + UDim2.fromOffset(x - point.X, y - point.Y))
        savedPosition, savedAnchor = main.Position, main.AnchorPoint
    end
    function self:SetDockPosition(value)
        local right = value == "Top right" or value == "Bottom right"
        local bottom = value == "Bottom left" or value == "Bottom right"
        dock.AnchorPoint = Vector2.new(right and 1 or 0, bottom and 1 or 0)
        dock.Position = UDim2.new(right and 1 or 0, right and -20 or 20, bottom and 1 or 0, bottom and -20 or 20)
        hint.Position = bottom and UDim2.fromOffset(0, -38) or UDim2.new(0, 0, 1, 6)
    end

    -- Keyboard navigation uses the same registered callbacks, not simulated mouse input.
    local focus = create("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 10000 }, main.Parent)
    create("UICorner", { CornerRadius = UDim.new(0, 5) }, focus)
    create("UIStroke", { Color = Color3.fromRGB(248, 220, 255), Thickness = 2 }, focus)
    local focused = nil
    local function visible(object)
        if not object:IsDescendantOf(main.Parent) or object.AbsoluteSize.X < 1 or object.AbsoluteSize.Y < 1 then return false end
        local center = object.AbsolutePosition + object.AbsoluteSize / 2
        local ancestor = object
        while ancestor and ancestor ~= main.Parent do
            if ancestor:IsA("GuiObject") then
                if not ancestor.Visible then return false end
                if ancestor.ClipsDescendants then
                    local p, s = ancestor.AbsolutePosition, ancestor.AbsoluteSize
                    if center.X < p.X or center.X > p.X + s.X or center.Y < p.Y or center.Y > p.Y + s.Y then return false end
                end
            end
            ancestor = ancestor.Parent
        end
        return true
    end
    local function updateFocus()
        if focused and focused.Parent and visible(focused) and Library.Toggled then
            focus.Position = UDim2.fromOffset(focused.AbsolutePosition.X - 2, focused.AbsolutePosition.Y - 2)
            focus.Size = UDim2.fromOffset(focused.AbsoluteSize.X + 4, focused.AbsoluteSize.Y + 4)
            focus.Visible = true
        else focus.Visible = false end
    end
    bind(Input.InputBegan, function(input, processed)
        if not Library.Toggled then return end
        local textbox = Input:GetFocusedTextBox()
        if input.KeyCode == Enum.KeyCode.Escape then
            hint.Visible = false
            if textbox then textbox:ReleaseFocus() end
            focused = nil; focus.Visible = false
            return
        end
        if textbox then return end
        local control = Input:IsKeyDown(Enum.KeyCode.LeftControl) or Input:IsKeyDown(Enum.KeyCode.RightControl)
        if control and input.KeyCode == Enum.KeyCode.M then Window:ToggleMinimized(); return end
        if control and input.KeyCode == Enum.KeyCode.Home then self:CenterWindow(); return end
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Tab then
            local candidates = {}
            for object in pairs(Library.ActivationHandlers) do
                if object.Active and object.Selectable and visible(object) then candidates[#candidates + 1] = object end
            end
            for _, object in ipairs(main:GetDescendants()) do
                if object:IsA("TextBox") and object.TextEditable and visible(object) then candidates[#candidates + 1] = object end
            end
            table.sort(candidates, function(a, b)
                local ay, by = math.floor(a.AbsolutePosition.Y / 8), math.floor(b.AbsolutePosition.Y / 8)
                if ay ~= by then return ay < by end
                return a.AbsolutePosition.X < b.AbsolutePosition.X
            end)
            if #candidates == 0 then return end
            local index = table.find(candidates, focused) or 0
            local reverse = Input:IsKeyDown(Enum.KeyCode.LeftShift) or Input:IsKeyDown(Enum.KeyCode.RightShift)
            focused = candidates[((index - 1 + (reverse and -1 or 1)) % #candidates) + 1]
            GuiService.SelectedObject = nil -- avoid simultaneous Roblox and custom activation
            updateFocus()
            hover(focused == dock)
        elseif focused and visible(focused) and (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Space) then
            if focused:IsA("TextBox") then focused:CaptureFocus()
            else
                local callback = Library.ActivationHandlers[focused]
                if callback then callback() end
            end
            updateFocus()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            focused = nil; focus.Visible = false
        end
    end)
    bind(main:GetPropertyChangedSignal("AbsolutePosition"), updateFocus)
    bind(main:GetPropertyChangedSignal("AbsoluteSize"), updateFocus)
    bind(main:GetPropertyChangedSignal("Visible"), updateFocus)
    self:SetOpaque(false)
    self:SetShadow("None")
    self:SetDockPosition("Top left")
    syncShell()
    Library:OnUnload(function()
        self.Alive = false
        stopPulse()
        self.Generation = self.Generation + 1
        for _, connection in ipairs(connections) do connection:Disconnect() end
        for _, tween in pairs(tweens) do tween:Cancel() end
        for _, object in ipairs(owned) do
            if Spring then Spring:Cancel(object) end
            Library:RemoveFromRegistry(object)
            object:Destroy()
        end
        Window.SetMinimized, Window.ToggleMinimized, Window.IsMinimized = old.Minimize, old.ToggleMinimized, old.IsMinimized
        Window.Toggle, Window.SetMinimizedSubtitle = old.Toggle, old.Subtitle
        Library.ActivationHandlers[dock] = nil
        Window.Cosmic = nil
    end)
    return self
end

return Cosmic
