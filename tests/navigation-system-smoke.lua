-- UI-only architecture regression; destroys temporary content and restores state.
local L=assert(getgenv().ObsidianPrimeDemo)
local P=L.PrimePreview
local main=L.Window.MainFrame
local previous=L.ActiveTab
local width=L.Window:GetSidebarWidth()
local font=L.Scheme.Font
local unread=L.NotificationUnreadCount
local temp
local function find(root,name) return assert(root:FindFirstChild(name,true),name) end
local function check(ok,message) assert(ok,message);print("[Navigation PASS]",message) end
local function near(a,b) return math.abs(a-b)<1 end
local ok,err=xpcall(function()
    check(string.find(font.Family,"BuilderSans",1,true)~=nil,"available Builder Sans default, not mislabeled SF Pro")
    local data=game:GetService("TextService"):GetFamilyInfoAsync(font.Family)
    check(data~=nil,"configured font family resolves in this client")
    check(not main:FindFirstChild("PrimeHeaderMove",true),"no header move icon")
    for _,side in ipairs({"Top","Left","Right","Bottom"}) do
        local edge=find(main,"PrimeDragEdge"..side)
        check(edge.Active and edge.BackgroundTransparency==1,"transparent drag edge "..side)
    end
    local center
    for _,name in ipairs({"PrimeHeaderTitle","PrimeHeaderSearch","PrimeHeaderBell","PrimeHeaderMinimize"}) do
        local object=find(main,name)
        local y=object.AbsolutePosition.Y+object.AbsoluteSize.Y/2
        center=center or y
        check(near(y,center),name.." shared centerline")
    end
    for _,tab in pairs(L.Tabs) do
        for _,sub in pairs(tab.SubTabs or {}) do check(sub.SidebarEntry==nil,"subcategories have a single controller") end
    end
    L.NotificationUnreadCount=128;L:UpdateNotificationBadge()
    local badge=L.NotificationBadge
    check(badge.Label.Text=="99+" and badge.Holder.Size.X.Offset>=22
        and badge.Holder.Position==UDim2.new(1,0,0,0),"count badge grows within bell corner")
    temp=L.Window:AddTab("A deliberately very long sidebar navigation label", "layers")
    temp:Show();task.wait(.4)
    local label=find(temp.Button,"PrimeSidebarLabel")
    for _,w in ipairs({180,240}) do
        L.Window:SetSidebarWidth(w);task.wait(.2)
        check(label.TextTruncate==Enum.TextTruncate.AtEnd and not label.TextWrapped
            and label.AbsolutePosition.X+label.AbsoluteSize.X<temp.Button.AbsolutePosition.X+temp.Button.AbsoluteSize.X,"sidebar label stays inside capsule")
    end
    local a=temp:AddSubTab("A long first category", "layers")
    local extra={}
    for i=2,12 do extra[#extra+1]=temp:AddSubTab("Category "..i,"layers") end
    task.wait(.5)
    local bar=find(temp.Container,"PrimeSubcategoryBar")
    local viewport=find(bar,"PrimeSubcategoryViewport")
    local recess=find(bar,"PrimeRecess")
    check(recess.AbsoluteSize.X<=bar.AbsoluteSize.X+1 and viewport.AbsoluteCanvasSize.X>viewport.AbsoluteSize.X,"many categories stay within one scrollable capsule")
    check(not find(bar,"PrimeLegacySubTabUnderline").Visible,"no subcategory underline")
    extra[#extra]:Show();task.wait(.3)
    check(viewport.CanvasPosition.X>0,"programmatic category selection scrolls into view")
    a:Show();task.wait(.3)
    check(viewport.CanvasPosition.X<1,"first category restores scroll position")
    for _,sub in ipairs(extra) do sub:Destroy() end
    task.wait(.3)
    temp:SetSubTabAlignment("Left");task.wait(.1)
    check(recess.AbsoluteSize.X<bar.AbsoluteSize.X and near(recess.AbsolutePosition.X,bar.AbsolutePosition.X),"capsule shrinks and realigns after removal")
    P.Showcase.Tabs.Layouts:Show();task.wait(.4)
    local group=P.Showcase.Groups.Collapsible
    group:SetPoppedOut(true);task.wait(.4)
    local body=find(group.Holder,"PrimeCardScroll")
    check(body.AbsolutePosition.X-group.Holder.AbsolutePosition.X>=3*L.DPIScale
        and group.Holder.AbsolutePosition.X+group.Holder.AbsoluteSize.X-body.AbsolutePosition.X-body.AbsoluteSize.X>=3*L.DPIScale,"card scroll is inset from both rims after pop-out")
    group:SetPoppedOut(false)
    for _,entry in ipairs(L.TabButtons) do
        if entry.Label and entry.Label.Parent then
            local holder=entry.Label.Parent
            local logo=find(main,"PrimeHeaderTitle")
            local footer=find(main,"PrimeFooter")
            local icon=entry.Icon
            local logoIcon=logo:FindFirstChildWhichIsA("ImageLabel")
            if icon and logoIcon then
                check(near(icon.AbsolutePosition.X+icon.AbsoluteSize.X/2,
                    logoIcon.AbsolutePosition.X+logoIcon.AbsoluteSize.X/2),"logo and sidebar icons share center axis")
            end
            local leading=holder.AbsolutePosition.X+entry.Padding.PaddingLeft.Offset*L.DPIScale
            check(near(leading,footer.AbsolutePosition.X+footer:FindFirstChildOfClass("UIPadding").PaddingLeft.Offset*L.DPIScale),"sidebar and footer share leading inset")
            break
        end
    end
end,debug.traceback)
if previous then previous:Show() end
if temp then temp:Destroy() end
L.Window:SetSidebarWidth(width)
L.NotificationUnreadCount=unread;L:UpdateNotificationBadge()
P.Showcase.Groups.Collapsible:SetPoppedOut(false)
if not ok then error(err,0) end
print("[Navigation SMOKE COMPLETE]")
