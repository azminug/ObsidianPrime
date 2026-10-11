-- State/lifecycle tests with Roblox primitives stubbed. Not a renderer test.
local function signal()
    local s = { callbacks = {} }
    function s:Connect(fn)
        local c = { Connected = true, fn = fn }
        function c:Disconnect() self.Connected = false end
        self.callbacks[#self.callbacks + 1] = c
        return c
    end
    function s:Fire(...)
        for _, c in ipairs(self.callbacks) do if c.Connected then c.fn(...) end end
    end
    return s
end
local vec = {}
vec.__index = vec
vec.__add = function(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y},vec) end
vec.__sub = function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y},vec) end
vec.__div = function(a,b) return setmetatable({X=a.X/b,Y=a.Y/b},vec) end
Vector2 = { new = function(x,y) return setmetatable({X=x,Y=y},vec) end }
local ud = {}
ud.__add = function(a,b) return UDim2.new(a.X.Scale+b.X.Scale,a.X.Offset+b.X.Offset,a.Y.Scale+b.Y.Scale,a.Y.Offset+b.Y.Offset) end
UDim2 = { new = function(xs,xo,ys,yo) return setmetatable({X={Scale=xs,Offset=xo},Y={Scale=ys,Offset=yo}},ud) end }
UDim2.fromOffset = function(x,y) return UDim2.new(0,x,0,y) end
UDim = { new = function(s,o) return {Scale=s,Offset=o} end }
local generic = function(...) return {...} end
Color3 = { fromRGB=generic }; ColorSequence={new=generic}; NumberSequence={new=generic}; NumberSequenceKeypoint={new=generic}
Rect={new=generic}; TweenInfo={new=generic}
Font={new=function(family,weight,style) return {Family=family,Weight=weight,Style=style} end}
Random={new=function() return {NextNumber=function(_,a,b) return (a+b)/2 end} end}
math.atan2=math.atan
Enum = setmetatable({}, {__index=function(t,k) local e=setmetatable({}, {__index=function(_,v) return v end});rawset(t,k,e);return e end})
math.clamp = function(x,a,b) return math.max(a,math.min(b,x)) end
table.find = function(t,v) for i,x in ipairs(t) do if x==v then return i end end end
local objects = {}
Instance = { new = function(class)
    local o={ ClassName=class, Visible=true, Active=true, Selectable=true, AbsoluteSize=Vector2.new(300,44),
        AbsolutePosition=Vector2.new(20,20), Position=UDim2.fromOffset(20,20), AnchorPoint=Vector2.new(0,0),
        signals={}, InputBegan=signal(), InputEnded=signal(), MouseEnter=signal(), MouseLeave=signal(), SelectionGained=signal(), SelectionLost=signal(), Activated=signal() }
    function o:GetPropertyChangedSignal(prop) self.signals[prop]=self.signals[prop] or signal();return self.signals[prop] end
    function o:FindFirstChild(name,recursive)
        for _,x in ipairs(objects) do if x.Name==name and (x.Parent==self or (recursive and x:IsDescendantOf(self))) then return x end end
    end
    function o:FindFirstChildOfClass(c) for _,x in ipairs(objects) do if x.Parent==self and x.ClassName==c then return x end end end
    function o:GetDescendants() local r={};for _,x in ipairs(objects) do if x:IsDescendantOf(self) then r[#r+1]=x end end;return r end
    function o:IsDescendantOf(p) local a=self.Parent;while a do if a==p then return true end;a=a.Parent end;return false end
    function o:IsA(c) return self.ClassName==c or (c=="GuiObject" and (self.ClassName=="Frame" or self.ClassName=="TextButton" or self.ClassName=="TextBox")) end
    function o:Destroy() self.Destroyed=true;self.Parent=nil end
    objects[#objects+1]=o;return o
end }
local deferred, pendingTweens = {}, {}
task={delay=function(_,fn) local item={fn=fn};deferred[#deferred+1]=item;return item end,cancel=function(item) item.cancelled=true end}
local TweenService={Create=function(_,object,_,properties)
    local t={};function t:Cancel() self.cancelled=true end
    function t:Play() pendingTweens[#pendingTweens+1]={t,object,properties} end
    return t
end}
local Input={InputBegan=signal(),InputChanged=signal(),InputEnded=signal(),MouseEnabled=true,KeyboardEnabled=true,GetFocusedTextBox=function() return nil end,IsKeyDown=function() return false end}
local GuiService={}
game={GetService=function(_,name) return ({TweenService=TweenService,UserInputService=Input,GuiService=GuiService})[name] end}
workspace={CurrentCamera={ViewportSize=Vector2.new(1280,720)}}
local function settle()
    for _,t in ipairs(pendingTweens) do if not t[1].cancelled then for k,v in pairs(t[3]) do t[2][k]=v end end end
    pendingTweens={}
    local work=deferred;deferred={};for _,item in ipairs(work) do if not item.cancelled then item.fn() end end
end
local root=Instance.new("ScreenGui")
local main=Instance.new("Frame");main.Parent=root
main.AbsoluteSize=Vector2.new(800,600)
local mini=Instance.new("Frame");mini.Parent=root
local scale=Instance.new("UIScale");scale.Scale=1;scale.Parent=main
local callbacks={}
local lib={Toggled=true,Registry={},Scheme={FontColor=Color3.fromRGB(247,243,250),AccentColor=Color3.fromRGB(220,180,240),Font=Font.new("BuilderSans","Regular","Normal")},ActivationHandlers={},OnUnload=function(_,fn) callbacks[#callbacks+1]=fn end}
function lib:GetCustomIcon() return nil end
function lib:RemoveFromRegistry(object) self.Registry[object]=nil end
function lib:OnActivate(button,fn) self.ActivationHandlers[button]=fn;return button.Activated:Connect(fn) end
local minimized=false
local win={MainFrame=main,MiniFrame=mini}
function win:IsMinimized() return minimized end
function win:SetMinimized(v) minimized=v;main.Visible=not v;mini.Visible=v end
function win:ToggleMinimized() self:SetMinimized(not minimized) end
function win:Toggle(v) lib.Toggled=v;main.Visible=v and not minimized;mini.Visible=v and minimized end
function win:SetMinimizedSubtitle(text) self.Subtitle=text end
function win:SetSizePosition(_,position) main.Position=position end
local original=win.SetMinimized
local Cosmic=dofile("addons/Cosmic.lua")
local c=Cosmic.new(lib,win)
assert(not win:IsMinimized() and not mini.Visible)
assert(c.TelemetryLabel.FontFace.Family==lib.Scheme.Font.Family and not c.Hint.Visible)
c.Dock.MouseEnter:Fire();assert(c.Hint.Visible)
c.Dock.MouseLeave:Fire();assert(not c.Hint.Visible)
Input.MouseEnabled=false;c.Dock.MouseEnter:Fire();assert(not c.Hint.Visible);Input.MouseEnabled=true
win:SetMinimized(true);settle();lib.ActivationHandlers[c.Dock]();settle();assert(not win:IsMinimized())
lib.ActivationHandlers[c.Dock]();assert(not win:IsMinimized(),"open capsule never minimizes")
c:SetTelemetry(60,111);assert(c.TelemetryLabel.Text=="60 FPS · 111 ms");settle()
c:SetReducedMotion(true);local count=#deferred;c:SetTelemetry(60,111);assert(#deferred==count);c:SetReducedMotion(false)
win:SetMinimized(true);assert(win:IsMinimized());settle()
assert(minimized and not main.Visible and not mini.Visible and scale.Scale==1)
win:SetMinimized(false);settle();assert(main.Visible and not minimized)
-- Latest intent wins, even while the previous transition has not completed.
win:SetMinimized(true);win:SetMinimized(false);win:SetMinimized(true);settle()
assert(minimized and not main.Visible and scale.Scale==1)
win:SetMinimized(false);c:SetReducedMotion(true);assert(main.Visible and not minimized);settle()
assert(not minimized and scale.Scale==1)
c:SetOpaque(true);assert(main.BackgroundTransparency==0)
c:SetShadow("Inset");assert(c.Shadow=="Inset")
assert(not pcall(function() c:SetShadow("Bad") end))
win:SetMinimizedSubtitle("Fishing / Waiting");assert(c.Status=="Fishing / Waiting")
c:SetReducedMotion(false)
win:SetMinimized(true);win:Toggle(false);settle()
assert(not main.Visible and not mini.Visible)
win:Toggle(true);win:SetMinimized(false);settle();assert(main.Visible)
win:SetMinimized(true)
c:SetTelemetry(60,90) -- unload with a pending heartbeat
for _,fn in ipairs(callbacks) do fn() end
settle();assert(not c.Alive and win.SetMinimized==original and win.Cosmic==nil)
print("PASS: minimize/restore, rapid reversal, reduced motion, hide during transition, opaque/shadows, unload")
