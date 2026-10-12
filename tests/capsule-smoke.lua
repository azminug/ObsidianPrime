-- Isolated UI fixture only. No gameplay, clipboard or profile writes.
local L=assert(getgenv().ImperiumPrimeMigrationPreview or getgenv().ObsidianPrimeDemo)
local A=(L.RAFPrime or L.PrimePreview).Appearance
local W=L.Window
local reduced,minimized,toggled=A.ReducedMotion,W:IsMinimized(),L.Toggled
local size,width=W.MainFrame.Size,W:GetSidebarWidth()
local function check(value,message) assert(value,message);print("[Capsule PASS]",message) end
local ok,err=xpcall(function()
    W:Toggle(true);A:SetReducedMotion(true)
    check(A.TelemetryLabel.FontFace.Family==L.Scheme.Font.Family,"capsule and menu share font family")
    check(A.DockLogo.Image~="" and A.Mascot:FindFirstChild("CatTail"),"logo and native pixel cat")
    check(A.Hint.TextTransparency==1,"no persistent restore prompt")
    for _,child in ipairs(A.Dock:GetChildren()) do
        if child:IsA("TextLabel") then
            check(child.Text~="Imperium" and child.Text~="+" and child.Text~="−","no redundant title or plus/minus")
        end
    end
    A:SetActiveCount(7);check(A.ActiveBadge.Text=="7","active automation badge")
    local idleWidth=A.Dock.Size.X.Offset
    A:SetCapsuleHover(true)
    check(A.Hint.Parent==A.Dock and A.Hint.Position.Y.Offset>=44 and A.Dock.Size.X.Offset==idleWidth and A.Dock.Size.Y.Offset==74,"hover expands down in one body")
    A:SetCapsuleHover(false)
    A:SetDockPosition("Top center");A:CenterWindow();task.wait(.1)
    check(A.Dock.AnchorPoint.X==.5 and A.Dock.Position.X.Scale==.5,"capsule starts at top center")
    check(A.Dock.AbsolutePosition.Y+A.Dock.AbsoluteSize.Y<W.MainFrame.AbsolutePosition.Y,"startup separates capsule and menu")
    W:SetMinimized(true)
    L.ActivationHandlers[A.Dock]()
    check(not W:IsMinimized() and W.MainFrame.Visible,"whole capsule restores menu")
    L.ActivationHandlers[A.Dock]()
    check(not W:IsMinimized(),"repeat activation keeps menu open")
    A:SetTelemetry(60,111)
    check(A.TelemetryLabel.Text=="60 FPS · 111 ms","performance metrics format")
    local line=A.Mascot
    local resting=line.Rotation
    task.wait(.3)
    check(line.Rotation==resting,"reduced motion holds mascot still")
    A:SetReducedMotion(false);A:SetTelemetry(60,111);task.wait(.12)
    check(math.abs(line.Rotation-resting)>.1,"real telemetry update animates mascot")
    local origin=W.MainFrame.Position
    W:SetMinimized(true);task.wait(.08);W:SetMinimized(false);task.wait(.08)
    W:SetMinimized(true);task.wait(.7)
    check(W:IsMinimized() and not W.MainFrame.Visible,"rapid reversal ends minimized")
    local center=A.Dock.AbsolutePosition+Vector2.new(A.Dock.AbsoluteSize.X/2,22)-W.MainFrame.Parent.AbsolutePosition
    check((A.MorphOrigin-center).Magnitude<2,"morph uses actual capsule center")
    W:SetMinimized(false);task.wait(.7)
    check(W.MainFrame.Visible and W.MainFrame.Position==origin,"restore preserves window position")
    W:Toggle(false);local hidden=line.Rotation
    A:SetTelemetry(60,111);task.wait(.3)
    check(not A.Dock.Visible and line.Rotation==hidden,"hidden capsule stops mascot")
    W:Toggle(true)
    for _,width in ipairs({480,892}) do
        W.MainFrame.Size=UDim2.fromOffset(width,650);task.wait(.1)
        local p,s=A.TelemetryLabel.AbsolutePosition,A.TelemetryLabel.AbsoluteSize
        check(p.X+s.X<=A.Dock.AbsolutePosition.X+A.Dock.AbsoluteSize.X-10,"metrics stay inside capsule")
    end
end,debug.traceback)
W.MainFrame.Size=size;W:SetSidebarWidth(width)
A:SetReducedMotion(reduced);W:Toggle(toggled);W:SetMinimized(minimized)
if not ok then error(err,0) end
print("[CAPSULE COMPLETE]")
