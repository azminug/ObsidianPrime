-- Shared, theme-aware material for existing and lazily created native Ultra UI.
-- Does not replace controls, callbacks, registries, menus, or persistence APIs.
local Materials = {}
function Materials.new(Library)
    local self = {Opaque=false, Alive=true, Surfaces=setmetatable({}, {__mode="k"}), Buttons=setmetatable({}, {__mode="k"}), Styled=setmetatable({}, {__mode="k"})}
    local connections, timers = {}, {}
    self.Tokens={WindowRadius=16,CardRadius=12,ControlRadius=8,CapsuleRadius=999,RimTopOpacity=.28,RimBottomOpacity=.09,HoverOpacity=.07,ScrollbarWidth=3}
    self.LockRadius=true
    local alphas = {Window=.48, Group=.36, Sidebar=.65, Header=.35, Panel=.20, Popup=.08, Control=.35, Recess=.20}
    local function animate(object,goals)
        if Library.PrimeMotion then Library.PrimeMotion:To(object,goals,30,1)
        else for key,value in pairs(goals) do object[key]=value end end
    end
    local function ownSignals(object,onDestroy)
        local owned={}
        local function bind(signal,fn)
            local connection=signal:Connect(fn);owned[#owned+1]=connection;connections[connection]=true
            return connection
        end
        bind(object.Destroying,function()
            if onDestroy then onDestroy() end
            for _,connection in ipairs(owned) do connection:Disconnect();connections[connection]=nil end
            table.clear(owned)
        end)
        return bind
    end
    function self:Radius(corner)
        if not self.LockRadius then return end
        local parent=corner.Parent
        if not parent then return end
        if parent.Name=="PrimeSidebarPane" then
            local radius=UDim.new(0,16)
            for key,value in pairs({CornerRadius=radius,TopLeftRadius=radius,BottomLeftRadius=radius,
                TopRightRadius=UDim.new(0,0),BottomRightRadius=UDim.new(0,0)}) do
                if corner[key]~=value then corner[key]=value end
            end
            return
        end
        local role=self.Surfaces[parent]
        local radius=parent:GetAttribute("ImperiumRadius")
        if not radius then
            radius=role=="Window" and 16 or role=="Group" and 12 or role=="Popup" and 12
                or role=="Recess" and 999 or role=="Control" and 8 or role=="Panel" and 8
        end
        if radius then
            local value=radius==999 and UDim.new(.5,0) or UDim.new(0,radius)
            if corner.CornerRadius~=value then corner.CornerRadius=value end
            for _,key in ipairs({"TopLeftRadius","TopRightRadius","BottomLeftRadius","BottomRightRadius"}) do
                if corner[key]~=value then corner[key]=value end
            end
        end
    end
    function self:SetRadiusHierarchy(enabled)
        self.LockRadius=enabled==true
        if self.LockRadius then
            for object in pairs(self.Styled) do if object.Parent and object:IsA("UICorner") then self:Radius(object) end end
        elseif Library.Window then
            Library.Window:SetCornerRadius(Library.CornerRadius)
        end
    end
    function self:StyleText(object)
        if self.Styled[object] then return end
        self.Styled[object]=true
        local role=object.Name=="PrimeTitle" and "Title" or (object:IsA("TextBox") or object.Name=="PrimeValue") and "Value" or "Label"
        object:SetAttribute("ImperiumTypography",role)
        local weight=role=="Title" and Enum.FontWeight.SemiBold or role=="Value" and Enum.FontWeight.Regular or Enum.FontWeight.Medium
        local registry=Library.Registry[object] or {};Library.Registry[object]=registry
        registry.FontFace=function() return Font.new(Library.Scheme.Font.Family,weight,Library.Scheme.Font.Style) end
        object.FontFace=registry.FontFace()
        if role=="Value" and (registry.TextColor3=="FontColor" or registry.TextColor3==nil) then
            registry.TextColor3=function() return Library.Scheme.FontColor:Lerp(Library.Scheme.AccentColor,.13) end
            object.TextColor3=registry.TextColor3()
        end
        if object.Name=="PrimeLabel" or object.Name=="PrimeValue" or object:IsA("TextButton") then
            object.TextTruncate=Enum.TextTruncate.AtEnd
            if object:IsA("TextButton") then object.TextWrapped=false end
        end
        if object:IsA("TextBox") then
            local bind=ownSignals(object)
            local ring=Instance.new("UIStroke")
            ring.Name="ImperiumFocusRing";ring.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            ring.Thickness=1;ring.Color=Library.Scheme.AccentColor;ring.Transparency=1;ring.Parent=object
            Library.Registry[ring]={Color="AccentColor"}
            bind(object.Focused,function() if object.TextEditable then animate(ring,{Transparency=0}) end end)
            bind(object.FocusLost,function() animate(ring,{Transparency=1}) end)
        end
    end
    function self:StyleScroll(object)
        if self.Styled[object] then return end
        self.Styled[object]=true
        object.ScrollBarThickness=self.Tokens.ScrollbarWidth
        object.VerticalScrollBarInset=Enum.ScrollBarInset.None
        object.ScrollBarImageColor3=Library.Scheme.FontColor
        Library.Registry[object]=Library.Registry[object] or {}
        Library.Registry[object].ScrollBarImageColor3="FontColor"
        object.ScrollBarImageTransparency=1
        local idle
        local function cancelIdle()
            if idle then timers[idle]=nil;task.cancel(idle);idle=nil end
        end
        local bind=ownSignals(object,cancelIdle)
        local function reveal()
            cancelIdle()
            animate(object,{ScrollBarImageTransparency=.35})
            idle=task.delay(.85,function()
                timers[idle]=nil
                idle=nil
                if self.Alive and object.Parent then animate(object,{ScrollBarImageTransparency=1}) end
            end)
            timers[idle]=true
        end
        bind(object:GetPropertyChangedSignal("CanvasPosition"),reveal)
        bind(object.MouseEnter,reveal)
    end
    local function color(role)
        local base = (role=="Window" or role=="Sidebar" or role=="Recess") and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
        return base:Lerp(Library.Scheme.FontColor, role=="Sidebar" and 0 or role=="Window" and .09 or .14)
    end
    function self:Apply(object, properties)
        if not self.Alive then return end
        local registry = Library.Registry[object]
        if object:IsA("UICorner") then
            self:Radius(object)
            if not self.Styled[object] then
                self.Styled[object]=true
                local bind=ownSignals(object)
                for _,key in ipairs({"CornerRadius","TopLeftRadius","TopRightRadius","BottomLeftRadius","BottomRightRadius"}) do
                    bind(object:GetPropertyChangedSignal(key),function() self:Radius(object) end)
                end
            end
            return
        end
        if object:IsA("UIStroke") then
            if object.Parent and object.Parent:GetAttribute("ImperiumRimOwner") and object.Name~="ImperiumMaterialRim" and registry then
                object.Enabled=false;return
            end
            if registry and registry.Color=="DarkColor" then object.Enabled=false
            elseif registry and registry.Color=="OutlineColor" and object.Transparency<1 then object.Transparency=.55 end
            return
        end
        if not object:IsA("GuiObject") then return end
        if object.Name=="PrimeSegment" or object.Name=="PrimeRecess" or object.Name=="PrimeSwitch" or object.Name=="PrimeSwitchThumb" or object.Name=="PrimeSliderThumb" or object.Name=="PrimeSliderTrack" then object:SetAttribute("ImperiumRadius",999) end
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then self:StyleText(object) end
        if object:IsA("ScrollingFrame") then self:StyleScroll(object) end
        if object.Name=="PrimeSettingRow" then self:BindButton(object) end
        if object.Name=="PrimeSidebar" or object.Name=="PrimeHeader" then
            object.BackgroundTransparency=1
            self.Surfaces[object]=nil
            return
        end
        if object.Name=="PrimeHairline" or object.Name=="Line" then
            object.BorderSizePixel=0;object.BackgroundColor3=Library.Scheme.FontColor;object.BackgroundTransparency=.78
            Library.Registry[object]={BackgroundColor3="FontColor"}
            if not object:FindFirstChild("ImperiumHairlineFade") then
                local fade=Instance.new("UIGradient");fade.Name="ImperiumHairlineFade"
                fade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)})
                fade.Parent=object
            end
            return
        end
        if object.Name=="ImperiumWindowDivider" or object.Name=="ImperiumSidebarDivider" then
            object.BackgroundTransparency=1
            -- Keep the invisible sidebar resize target and its callbacks intact.
            return
        end
        local role=self.Surfaces[object]
        if not role then
            if object.Name=="Main" and object.Parent and object.Parent:IsA("ScreenGui") then role="Window"
            elseif object.Name=="PrimeGroupedSurface" then role="Group"
            elseif object.Name=="PrimeTabboxSurface" and object.BackgroundTransparency<.95 then role="Group"
            elseif object.Name=="PrimeSidebarPane" then role="Sidebar"
            elseif object.Name=="PrimeHeaderSurface" then role="Header"
            elseif object.Name=="PrimeRecess" then role="Recess"
            elseif object.Name=="PrimePopup" then role="Popup"
            elseif object.BackgroundTransparency<.95 and registry then
                local token=registry.BackgroundColor3
                if token=="MainColor" or token=="BackgroundColor" then
                    role=(object:IsA("GuiButton") or object:IsA("TextBox")) and "Control" or "Panel"
                end
            end
        end
        if not role then return end
        self.Surfaces[object]=role
        object:SetAttribute("ImperiumMaterial",role)
        registry=registry or {};Library.Registry[object]=registry
        registry.BackgroundColor3=function() return color(role) end
        object.BackgroundColor3=color(role)
        object.BackgroundTransparency=self.Opaque and 0 or alphas[role]
        for _,child in ipairs(object:GetChildren()) do if child:IsA("UICorner") then self:Apply(child) end end
        if role=="Header" and not object:FindFirstChild("ImperiumHeaderFalloff") then
            -- Preserve the readable title area, dissolve the lower edge into the sheet.
            local falloff=Instance.new("UIGradient")
            falloff.Name="ImperiumHeaderFalloff";falloff.Rotation=90
            falloff.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.79,0),NumberSequenceKeypoint.new(1,1)})
            falloff.Enabled=not self.Opaque;falloff.Parent=object
        end
        -- One subtle rim; native outlines still supply geometry and hit targets.
        if (role=="Panel" or role=="Group" or role=="Popup") and not object:FindFirstChild("ImperiumMaterialRim") then
            object:SetAttribute("ImperiumRimOwner",true)
            for _,child in ipairs(object:GetChildren()) do
                if child:IsA("UIStroke") and Library.Registry[child] then child.Enabled=false end
            end
            local rim=Instance.new("UIStroke")
            rim.Name="ImperiumMaterialRim";rim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            rim.Color=Library.Scheme.FontColor;rim.Transparency=0;rim.Thickness=1;rim.Parent=object
            Library.Registry[rim]={Color="FontColor"}
            local reflection=Instance.new("UIGradient")
            reflection.Rotation=90
            reflection.Transparency=NumberSequence.new(.72,.91)
            reflection.Parent=rim
            if role=="Group" then
                -- Concentric low-opacity edges: no layout siblings, hit targets or render loop.
                for index,width in ipairs({3,6,10}) do
                    local shadow=Instance.new("UIStroke")
                    shadow.Name="ImperiumSoftShadow";shadow.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
                    shadow.Color=Color3.fromRGB(13,10,22);shadow.Thickness=width
                    shadow.Transparency=({.91,.955,.98})[index];shadow.ZIndex=-index;shadow.Parent=object
                    local falloff=Instance.new("UIGradient");falloff.Rotation=90
                    falloff.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.45,.65),NumberSequenceKeypoint.new(1,0)})
                    falloff.Parent=shadow
                end
                local sheen=Instance.new("UIGradient")
                sheen.Name="ImperiumGlassDepth";sheen.Rotation=118
                sheen.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(.4,Color3.fromRGB(246,242,252)),ColorSequenceKeypoint.new(1,Color3.fromRGB(211,205,222))})
                sheen.Parent=object
            end
        end
    end
    function self:BindButton(button)
        local passive=button.Name=="PrimeSettingRow"
        if not self.Alive or self.Buttons[button] or (not passive and not button:IsA("GuiButton")) then return end
        self.Buttons[button]=true
        local glow=Instance.new("Frame")
        glow.Name="ImperiumSpecular";glow.Active=false;glow.Interactable=false
        glow.BackgroundColor3=Color3.new(1,1,1);glow.BackgroundTransparency=1
        glow.BorderSizePixel=0;glow.Size=UDim2.fromScale(1,1);glow.ZIndex=button.ZIndex;glow.Parent=button
        local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=glow
        local gradient=Instance.new("UIGradient")
        -- Retain a white wash over the entire body, with a small specular variation.
        gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,.15)})
        gradient.Parent=glow
        local bind=ownSignals(button)
        local function syncGeometry()
            local pad=button:FindFirstChildOfClass("UIPadding")
            local l,r,t,b=UDim.new(0,0),UDim.new(0,0),UDim.new(0,0),UDim.new(0,0)
            if pad then l,r,t,b=pad.PaddingLeft,pad.PaddingRight,pad.PaddingTop,pad.PaddingBottom end
            -- GuiObject children inherit the content inset. Undo it only for decoration.
            glow.Position=UDim2.new(-l.Scale,-l.Offset,-t.Scale,-t.Offset)
            glow.Size=UDim2.new(1+l.Scale+r.Scale,l.Offset+r.Offset,1+t.Scale+b.Scale,t.Offset+b.Offset)
            local source=button:FindFirstChildOfClass("UICorner")
            local radius=button:GetAttribute("ImperiumRadius")
            if not radius and button.Name=="PrimeSubcategoryButton" then radius=999 end
            local value=radius==999 and UDim.new(.5,0) or radius and UDim.new(0,radius) or source and source.CornerRadius or UDim.new(0,8)
            corner.CornerRadius=value
            for _,key in ipairs({"TopLeftRadius","TopRightRadius","BottomLeftRadius","BottomRightRadius"}) do
                corner[key]=radius and value or source and source[key] or value
            end
        end
        local function track(child)
            if child:IsA("UIPadding") or child:IsA("UICorner") then bind(child.Changed,syncGeometry) end
        end
        for _,child in ipairs(button:GetChildren()) do track(child) end
        bind(button.ChildAdded,function(child) track(child);syncGeometry() end)
        bind(button.ChildRemoved,syncGeometry)
        bind(button:GetAttributeChangedSignal("ImperiumRadius"),syncGeometry)
        syncGeometry()
        bind(button.MouseMoved,function(x)
            gradient.Offset=Vector2.new(math.clamp((x-button.AbsolutePosition.X)/math.max(1,button.AbsoluteSize.X)-.5,-.2,.2),0)
        end)
        local hovering=false
        local function enabled() return passive or (button.Active and button.Interactable) end
        bind(button.MouseEnter,function() hovering=true;if enabled() then animate(glow,{BackgroundTransparency=.93}) end end)
        bind(button.MouseLeave,function() hovering=false;animate(glow,{BackgroundTransparency=1}) end)
        if not passive then
            bind(button.InputBegan,function(i) if enabled() and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then animate(glow,{BackgroundTransparency=.92}) end end)
            bind(button.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then animate(glow,{BackgroundTransparency=hovering and .93 or 1}) end end)
        end
    end
    function self:SetOpaque(value)
        self.Opaque=value==true
        for object,role in pairs(self.Surfaces) do
            if object.Parent then
                object.BackgroundTransparency=self.Opaque and 0 or alphas[role]
                local falloff=object:FindFirstChild("ImperiumHeaderFalloff")
                if falloff then falloff.Enabled=not self.Opaque end
            end
        end
    end
    Library.PrimeMaterial=self
    for _,root in ipairs({Library.ScreenGui,Library.Overlay}) do
        if root then for _,object in ipairs(root:GetDescendants()) do self:Apply(object) end end
    end
    for button in pairs(Library.ActivationHandlers) do self:BindButton(button) end
    Library:OnUnload(function()
        self.Alive=false
        for timer in pairs(timers) do task.cancel(timer) end
        table.clear(timers)
        for connection in pairs(connections) do connection:Disconnect() end
        table.clear(connections)
        Library.PrimeMaterial=nil
    end)
    return self
end
return Materials
