-- Camera-local glass + near-field depth of field. Owns only its own instances.
-- Roblox graphics quality can disable/refuse this effect; readable mode is available.
local Acrylic = {}
function Acrylic.new(Library, Window)
    local Run = game:GetService("RunService")
    local effect = Instance.new("DepthOfFieldEffect")
    effect.Name = "ImperiumAcrylicDOF"
    effect.FarIntensity = 0
    effect.NearIntensity = 0.9
    effect.FocusDistance = 10
    effect.InFocusRadius = 9
    effect.Enabled = false
    local blur = Instance.new("BlurEffect")
    blur.Name = "ImperiumWorldBlur"
    blur.Size = 14
    blur.Enabled = false
    local pane = Instance.new("Part")
    pane.Name = "ImperiumCameraGlass"
    pane.Anchored, pane.CanCollide, pane.CanTouch, pane.CanQuery, pane.CastShadow = true, false, false, false, false
    pane.Material = Enum.Material.Glass
    pane.Color = Color3.fromRGB(191, 186, 208)
    pane.Transparency = 0.97
    pane.Reflectance = 0.02
    local self = { Enabled = true, Alive = true, Available = true }
    local camera, connection, warning = nil, nil, false
    local function update()
        if not self.Alive then return end
        local current = workspace.CurrentCamera
        if current ~= camera then
            camera = current
            pane.Parent, effect.Parent, blur.Parent = camera, camera, camera
        end
        local frame = Window.MainFrame
        local visible = self.Enabled and camera and frame and frame.Visible and Library.Toggled
        effect.Enabled = visible == true
        blur.Enabled = visible == true
        pane.Transparency = visible and 0.97 or 1
        if not visible then return end
        local p, s = frame.AbsolutePosition, frame.AbsoluteSize
        local depth = 0.65
        -- ScreenPointToRay accounts for Roblox's GUI inset, matching AbsolutePosition.
        local top = camera:ScreenPointToRay(p.X + 8, p.Y + 8, depth).Origin
        local bottom = camera:ScreenPointToRay(p.X + s.X - 8, p.Y + s.Y - 8, depth).Origin
        local a, b = camera.CFrame:PointToObjectSpace(top), camera.CFrame:PointToObjectSpace(bottom)
        pane.Size = Vector3.new(math.max(0.01, math.abs(b.X-a.X)), math.max(0.01, math.abs(b.Y-a.Y)), 0.01)
        pane.CFrame = camera.CFrame * CFrame.new((a+b)/2)
    end
    function self:SetEnabled(value)
        self.Enabled = value == true
        update()
    end
    connection = Run.RenderStepped:Connect(function()
        local ok, err = pcall(update)
        if not ok then
            self.Available, self.Enabled = false, false
            effect.Enabled, blur.Enabled, pane.Transparency = false, false, 1
            if not warning then warning=true;warn("[Imperium Acrylic] " .. tostring(err)) end
        end
    end)
    Library:OnUnload(function()
        self.Alive = false
        connection:Disconnect()
        pane:Destroy();effect:Destroy();blur:Destroy()
    end)
    return self
end
return Acrylic
