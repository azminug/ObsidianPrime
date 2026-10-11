-- UI-only geometry regression. Run in the migration fixture or native workbench.
local L=assert(getgenv().ImperiumPrimeMigrationPreview or getgenv().ObsidianPrimeDemo)
local W=L.Window
local main=W.MainFrame
local oldSize,oldWidth,oldTab=main.Size,W:GetSidebarWidth(),L.ActiveTab
local oldDPI=L.DPIScale
local temp
local function check(value,message) assert(value,message);print("[Responsive PASS]",message) end
local function find(root,name) return assert(root:FindFirstChild(name,true),name) end
local function near(a,b) return math.abs(a-b)<1.5 end
local ok,err=xpcall(function()
    L:SetDPIScale(100)
    main.Size=UDim2.fromOffset(800,650);task.wait(.15)
    W:SetSidebarWidth(240)
    local previousLogo=0
    for _,width in ipairs({480,680,892}) do
        main.Size=UDim2.fromOffset(width,650);task.wait(.25)
        check(near(W:GetSidebarWidth(),width*.3),"sidebar follows window width "..width)
        check(W:GetSidebarWidth()>=128,"expanded sidebar respects minimum")
        local title=find(main,"PrimeHeaderTitle")
        local logo=title:FindFirstChildWhichIsA("ImageLabel") or title:FindFirstChildWhichIsA("TextLabel")
        local titleText=find(title,"PrimeTitle")
        if W:GetSidebarWidth()<180 then
            check(not titleText.Visible,"narrow banner shows logo only")
            check(near(logo.AbsolutePosition.X+logo.AbsoluteSize.X/2,title.AbsolutePosition.X+title.AbsoluteSize.X/2),"compact brand remains centered")
        else
            check(titleText.Visible,"wide banner exposes title")
            check(near(logo.AbsolutePosition.X-title.AbsolutePosition.X,12),"brand row shares consistent inset")
            check(titleText.AbsolutePosition.X+titleText.AbsoluteSize.X<=title.AbsolutePosition.X+title.AbsoluteSize.X-11,"title fits banner")
        end
        check(logo.AbsoluteSize.X>previousLogo,"logo grows with sidebar")
        previousLogo=logo.AbsoluteSize.X
        local banner=find(main,"PrimeSidebarBanner")
        check(near(banner.AbsoluteSize.X,W:GetSidebarWidth()),"banner fills sidebar width")
        check(banner:FindFirstChild("ImperiumBannerFalloff")~=nil and not banner:FindFirstChildOfClass("UIStroke"),"banner gradient has no capsule outline")
        check(logo.AbsolutePosition.Y-title.AbsolutePosition.Y>=4-1 and title.AbsolutePosition.Y+title.AbsoluteSize.Y-logo.AbsolutePosition.Y-logo.AbsoluteSize.Y>=4-1,"logo has vertical inset")
        local sidebar=find(main,"PrimeSidebar")
        sidebar.CanvasPosition=Vector2.zero
        local contentTop=sidebar.AbsolutePosition.Y+sidebar:FindFirstChildOfClass("UIPadding").PaddingTop.Offset
        check(near(contentTop-title.AbsolutePosition.Y-title.AbsoluteSize.Y,4),"brand-to-navigation clearance remains compact")
        local footer=find(main,"PrimeFooter")
        local content=find(main,"Container")
        check(near(footer.AbsolutePosition.X+footer.AbsoluteSize.X/2,content.AbsolutePosition.X+content.AbsoluteSize.X/2),"footer centered in content span")
        for _,child in ipairs(footer:GetChildren()) do
            if child:IsA("GuiObject") then
                check(child.AbsolutePosition.X>=footer.AbsolutePosition.X+39 and child.AbsolutePosition.X+child.AbsoluteSize.X<=footer.AbsolutePosition.X+footer.AbsoluteSize.X-39,"footer content clears resize reserves")
            end
        end
    end
    W:SetCompact(true);local compactWidth=W:GetSidebarWidth()
    main.Size=UDim2.fromOffset(600,650);task.wait(.2)
    check(W:GetSidebarWidth()==compactWidth,"explicit compact mode survives resize")
    W:SetCompact(false);W:SetSidebarWidth(180)
    main.Size=UDim2.fromOffset(800,650);task.wait(.2)
    check(near(W:GetSidebarWidth(),240),"manual sidebar proportion is preserved")
    main.Size=UDim2.fromOffset(420,650);task.wait(.2)
    check(W:GetSidebarWidth()==128,"automatic sidebar clamps at minimum")
    main.Size=UDim2.fromOffset(892,650)
    temp=W:AddTab("Responsive capsule test","layers")
    local a=temp:AddSubTab("First")
    local b=temp:AddSubTab("Second")
    local group=a:AddLeftGroupbox("Spacing")
    group:AddLabel("Read-only layout fixture")
    temp:Show();a:Show();task.wait(.3)
    local rail=find(temp.Container,"PrimeSubcategoryBar")
    check(near(rail.AbsoluteSize.Y/L.DPIScale,32),"subcategory uses tabbox rail height")
    local gap=(group.BoxHolder.AbsolutePosition.Y-rail.AbsolutePosition.Y-rail.AbsoluteSize.Y)/L.DPIScale
    check(gap>=4 and gap<=8,"compact 4–8px capsule-to-module gap")
    for _=1,8 do b:Show();a:Show() end
    task.wait(.3)
    check(temp.ActiveSubTab==a,"rapid subcategory reversal retains latest selection")
    L:SetDPIScale(125);task.wait(.3)
    local footer=find(main,"PrimeFooter");local content=find(main,"Container")
    check(near(footer.AbsolutePosition.X+footer.AbsoluteSize.X/2,content.AbsolutePosition.X+content.AbsoluteSize.X/2),"content footer alignment survives DPI")
end,debug.traceback)
if temp then temp:Destroy() end
L:SetDPIScale(oldDPI*100)
main.Size=oldSize;task.wait(.1);W:SetSidebarWidth(oldWidth)
if oldTab then oldTab:Show() end
if not ok then error(err,0) end
print("[RESPONSIVE SHELL COMPLETE]")
