-- Application composition. Native options remain the source of truth for persistence.
local Interface = {}
function Interface.new(Library, Window)
    local self = {}
    local function make(class, parent, props)
        local object = Instance.new(class)
        for key,value in pairs(props or {}) do object[key]=value end
        object.Parent=parent
        if object:IsA("GuiObject") then object.BorderSizePixel=0 end
        return object
    end
    local function corner(object, radius)
        object:SetAttribute("ImperiumRadius", radius)
        local existing=object:FindFirstChildOfClass("UICorner")
        if existing then existing.CornerRadius=UDim.new(0,radius)
        else make("UICorner",object,{CornerRadius=UDim.new(0,radius)}) end
    end
    local function text(parent, value, props)
        local label=make("TextLabel",parent,{BackgroundTransparency=1,Text=value,TextColor3=Color3.fromRGB(237,233,244),
            TextSize=14,Font=Enum.Font.BuilderSans,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        for key,v in pairs(props or {}) do label[key]=v end
        return label
    end
    local function button(parent, caption, props, callback)
        local b=make("TextButton",parent,{Text=caption,TextSize=14,Font=Enum.Font.BuilderSansMedium,
            BackgroundColor3=Color3.fromRGB(55,52,65),TextColor3=Color3.fromRGB(242,237,249),
            AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,36)})
        for key,v in pairs(props or {}) do b[key]=v end
        corner(b,8)
        make("UIPadding",b,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
        if callback then Library:OnActivate(b,callback) end
        if Library.PrimeMaterial then Library.PrimeMaterial:Apply(b) end
        return b
    end
    function self:Banner(group, image, title, subtitle)
        local host=make("Frame",group.Container,{Name="PrimeBanner",BackgroundTransparency=1,Size=UDim2.new(1,0,0,80)})
        local avatar=make("ImageLabel",host,{Image=image or "",BackgroundColor3=Color3.fromRGB(55,52,65),
            Size=UDim2.fromOffset(56,56),Position=UDim2.fromOffset(4,12),ScaleType=Enum.ScaleType.Crop})
        corner(avatar,16)
        text(host,title,{Position=UDim2.fromOffset(72,8),Size=UDim2.new(1,-76,0,24),Font=Enum.Font.BuilderSansBold})
        text(host,subtitle,{Position=UDim2.fromOffset(72,34),Size=UDim2.new(1,-76,0,42),TextWrapped=true,
            TextSize=12,TextColor3=Color3.fromRGB(196,190,209),TextYAlignment=Enum.TextYAlignment.Top})
        group:Resize()
        return host
    end
    -- One occupied column expands; narrow pages stack both native columns in order.
    -- Ownership tables and native control objects are retained during reflow.
    function self:Adaptive(page)
        if page.PrimeAdaptive or not page.Sides or page.Sides[1]==page.Sides[2] then return end
        page.PrimeAdaptive=true
        local left,right=page.Sides[1],page.Sides[2]
        local canvas=page.Container or page.Canvas
        local origins=setmetatable({},{__mode="k"})
        local original=page.RefreshSides
        local busy=false
        local function content(side)
            for _,child in ipairs(side:GetChildren()) do if child:IsA("GuiObject") and child.Visible and #child:GetChildren()>0 then return true end end
            return false
        end
        function page:RefreshSides(...)
            if busy or page.Destroyed then return end
            busy=true
            original(self,...)
            local narrow=canvas.AbsoluteSize.X/Library.DPIScale<580
            for object,home in pairs(origins) do
                if object.Parent then
                    local target=narrow and left or home
                    if object.Parent~=target then object.Parent=target end
                end
            end
            local a,b=content(left),content(right)
            for index,side in ipairs({left,right}) do
                local full=narrow or a~=b
                side.Position=UDim2.new(index-1,0,side.Position.Y.Scale,side.Position.Y.Offset)
                side.Size=UDim2.new(full and 1 or .5,full and 0 or -3,side.Size.Y.Scale,side.Size.Y.Offset)
                -- An empty full-width sibling must never intercept the occupied column.
                side.Visible=index==1 and a or (index==2 and b and not narrow)
                side.Active=side.Visible
                side.ScrollingEnabled=side.Visible
                side.AutomaticCanvasSize=Enum.AutomaticSize.Y
                side.CanvasSize=UDim2.new()
            end
            busy=false
        end
        local function observe(object,side)
            if not object:IsA("GuiObject") or origins[object] then return end
            origins[object]=side
            Library:GiveSignal(object:GetPropertyChangedSignal("Visible"):Connect(function() page:RefreshSides() end))
        end
        for _,side in ipairs({left,right}) do
            for _,object in ipairs(side:GetChildren()) do observe(object,side) end
            Library:GiveSignal(side.ChildAdded:Connect(function(object) observe(object,side);page:RefreshSides() end))
            local padding=side:FindFirstChildOfClass("UIPadding")
            if padding then padding.PaddingBottom=UDim.new(0,18) end
        end
        Library:GiveSignal(canvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() page:RefreshSides() end))
        page:RefreshSides()
        for _,sub in pairs(page.SubTabs or {}) do self:Adaptive(sub) end
    end
    -- Tap inspects; double tap or the inline check edits a draft;
    -- only Apply calls the existing option callback. Cancel never mutates the option.
    function self:Browser(info)
        if Library.ActiveDialog then return end
        local draft={};for id,on in pairs(info.Option.Value) do if on then draft[id]=true end end
        local dialog=Window:AddDialog(info.Id,{Title=info.Title,Description=info.Description or "Tap to inspect · double tap to select · drag a check to select several. Apply saves.",
            Width=760,OutsideClickDismiss=true,InstantOutsideDismiss=true,FooterButtons={{Title="Cancel",Variant="Secondary"},
                {Title="Apply",Callback=function() info.Option:SetValue(draft);if info.Applied then info.Applied(draft) end end}}})
        local root=make("Frame",dialog.Container,{Name="PrimeItemBrowser",BackgroundTransparency=1,Size=UDim2.new(1,0,0,350)})
        local search=make("TextBox",root,{Name="Search",PlaceholderText="Search items…",Text="",ClearTextOnFocus=false,
            Font=Enum.Font.BuilderSans,TextSize=14,TextColor3=Color3.fromRGB(241,237,248),PlaceholderColor3=Color3.fromRGB(188,180,201),
            BackgroundColor3=Color3.fromRGB(48,45,58),Size=UDim2.new(1,0,0,36),TextXAlignment=Enum.TextXAlignment.Left})
        corner(search,8);make("UIPadding",search,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
        if Library.PrimeMaterial then Library.PrimeMaterial:Apply(search) end
        local categories=make("ScrollingFrame",root,{Name="Categories",BackgroundTransparency=1,Position=UDim2.fromOffset(0,44),
            Size=UDim2.new(1,0,0,40),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=3,
            ScrollingDirection=Enum.ScrollingDirection.X})
        make("UIListLayout",categories,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
        local list=make("ScrollingFrame",root,{Name="Items",BackgroundTransparency=1,Position=UDim2.fromOffset(0,94),
            Size=UDim2.new(.48,-6,1,-138),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3})
        make("UIListLayout",list,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
        make("UIPadding",list,{PaddingTop=UDim.new(0,2),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
        local detail=make("ScrollingFrame",root,{Name="Detail",BackgroundColor3=Color3.fromRGB(43,40,53),
            Position=UDim2.new(.48,6,0,94),Size=UDim2.new(.52,-6,1,-94),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3})
        corner(detail,12);make("UIListLayout",detail,{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
        make("UIPadding",detail,{PaddingTop=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingBottom=UDim.new(0,12)})
        local art=make("ImageLabel",detail,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,78),ScaleType=Enum.ScaleType.Fit,LayoutOrder=1})
        local description=text(detail,"Select an item",{Name="Description",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            RichText=true,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,LayoutOrder=2})
        local current,category=nil,"All"
        local rows,categoryButtons={},{}
        local empty=text(list,"No matching items",{Size=UDim2.new(1,0,0,44),Visible=false,TextWrapped=true})
        local actionButton
        local checks={}
        local function paint()
            for id,check in pairs(checks) do
                check.Text=draft[id] and "✓" or "+"
                check.BackgroundColor3=draft[id] and Color3.fromRGB(95,78,119) or Color3.fromRGB(55,52,65)
                check:SetAttribute("Selected",draft[id]==true)
            end
        end
        local function focus(id)
            current=id
            local details=info.Inspect and info.Inspect(id) or {Text=info.Names[id] or id}
            if dialog.Destroyed then return end
            description.Text=details.Text or info.Names[id] or id
            local icon=type(details.Image)=="table" and details.Image or Library:GetCustomIcon(details.Image)
            art.Visible=icon~=nil
            if icon then
                art.Image=icon.Url or icon.Image or ""
                art.ImageRectOffset=icon.ImageRectOffset or Vector2.zero
                art.ImageRectSize=icon.ImageRectSize or Vector2.zero
            end
            if actionButton then actionButton.Visible=details.ActionEnabled==true end
            for key,row in pairs(rows) do row.BackgroundColor3=key==id and Color3.fromRGB(77,68,91) or Color3.fromRGB(48,45,57) end
            paint()
        end
        local function select(id,value)
            if dialog.Destroyed or not rows[id] then return end
            draft[id]=value and true or nil;paint()
        end
        local lastId,lastTap=nil,0
        local function activate(id)
            local now=os.clock()
            if lastId==id and now-lastTap<=.35 then
                select(id,not draft[id]);lastId=nil;lastTap=0
            else lastId=id;lastTap=now end
            focus(id)
        end
        if info.Action then actionButton=button(detail,info.ActionText or "Use item",{LayoutOrder=4},function() if current then info.Action(current);focus(current) end end) end
        local function filter()
            local query=search.Text:lower()
            local shown=0
            for id,row in pairs(rows) do
                row.Visible=(category=="All" or info.Category and info.Category[id]==category) and (info.Names[id] or id):lower():find(query,1,true)~=nil
                if row.Visible then shown=shown+1 end
            end
            empty.Visible=shown==0
            for key,b in pairs(categoryButtons) do b.BackgroundColor3=key==category and Color3.fromRGB(77,68,91) or Color3.fromRGB(48,45,57) end
        end
        local names={"All"};for _,name in ipairs(info.Categories or {}) do names[#names+1]=name end
        for index,name in ipairs(names) do
            local b=button(categories,name,{Size=UDim2.fromOffset(math.max(64,#name*8+24),34),LayoutOrder=index},function() category=name;filter() end)
            corner(b,999);categoryButtons[name]=b
        end
        for index,id in ipairs(info.Ids) do
            local row=button(list,info.Names[id] or id,{Name=id,Size=UDim2.new(1,0,0,44),LayoutOrder=index,TextXAlignment=Enum.TextXAlignment.Left},function() activate(id) end)
            row:FindFirstChildOfClass("UIPadding").PaddingRight=UDim.new(0,44)
            make("UIStroke",row,{Thickness=1,Color=Color3.fromRGB(170,158,185),Transparency=.72})
            rows[id]=row
            local check=button(row,"+",{Name="SelectItem",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,38,.5,0),Size=UDim2.fromOffset(32,32)},nil)
            -- UIPadding offsets the row's child coordinate space as well as its text.
            check:FindFirstChildOfClass("UIPadding"):Destroy()
            checks[id]=check
        end
        -- A drag begins on the explicit check target, leaving ordinary touch swipes
        -- available for scrolling the list. All rows traversed receive one value.
        local inputService=game:GetService("UserInputService")
        local drag,dragPoint,dragLast,dragValue,dragMoved,visited
        local connections={}
        local suppress={}
        for id,check in pairs(checks) do
            connections[#connections+1]=check.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                    drag=input;dragPoint=Vector2.new(input.Position.X,input.Position.Y)
                    dragLast=dragPoint
                    dragValue=not draft[id];dragMoved=false;visited={};visited[id]=true
                end
            end)
            Library:OnActivate(check,function()
                if suppress[id] then suppress[id]=nil;return end
                select(id,not draft[id])
            end)
        end
        connections[#connections+1]=inputService.InputChanged:Connect(function(input)
            if not drag or (input~=drag and input.UserInputType~=Enum.UserInputType.MouseMovement) then return end
            local point=Vector2.new(input.Position.X,input.Position.Y)
            if not dragMoved and (point-dragPoint).Magnitude<8 then return end
            if not dragMoved then
                dragMoved=true;list.ScrollingEnabled=false
                for id in pairs(visited) do select(id,dragValue);suppress[id]=true end
            end
            local p,s=list.AbsolutePosition,list.AbsoluteSize
            local from=dragLast;dragLast=point
            if point.X<p.X or point.X>p.X+s.X or point.Y<p.Y or point.Y>p.Y+s.Y then return end
            local low=math.max(p.Y,math.min(from.Y,point.Y))
            local high=math.min(p.Y+s.Y,math.max(from.Y,point.Y))
            for id,row in pairs(rows) do
                if row.Visible and not visited[id] and row.AbsolutePosition.Y<=high and row.AbsolutePosition.Y+row.AbsoluteSize.Y>=low then
                    visited[id]=true;select(id,dragValue)
                end
            end
        end)
        connections[#connections+1]=inputService.InputEnded:Connect(function(input)
            if input~=drag then return end
            drag=nil;list.ScrollingEnabled=true
            task.delay(.2,function() table.clear(suppress) end)
        end)
        local actions=make("Frame",root,{BackgroundTransparency=1,Position=UDim2.new(0,0,1,-36),Size=UDim2.new(.48,-6,0,36)})
        local selectAll=button(actions,"Select shown",{Size=UDim2.new(.5,-3,1,0)},function() for id,row in pairs(rows) do if row.Visible then draft[id]=true end end;paint() end)
        local clearAll=button(actions,"Clear shown",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0)},function() for id,row in pairs(rows) do if row.Visible then draft[id]=nil end end;paint() end)
        search:GetPropertyChangedSignal("Text"):Connect(filter)
        if Library.PrimeMaterial then for _,scroll in ipairs({categories,list,detail}) do Library.PrimeMaterial:Apply(scroll) end end
        dialog:Resize();filter();paint()
        if info.Ids[1] then focus(info.Ids[1]) end
        -- Fit short windows without letting content cover the native footer actions.
        local function resize()
            root.Size=UDim2.new(1,0,0,math.clamp(Window.MainFrame.AbsoluteSize.Y/Library.DPIScale-210,220,430));dialog:Resize()
            local narrow=root.AbsoluteSize.X/Library.DPIScale<440
            actions.Position=UDim2.new(0,0,1,narrow and -80 or -36)
            actions.Size=UDim2.new(.48,-6,0,narrow and 80 or 36)
            list.Size=UDim2.new(.48,-6,1,narrow and -182 or -138)
            selectAll.Size=narrow and UDim2.new(1,0,0,36) or UDim2.new(.5,-3,1,0)
            clearAll.Size=selectAll.Size
            clearAll.Position=narrow and UDim2.fromOffset(0,44) or UDim2.new(.5,3,0,0)
        end
        local resizeConnection=Window.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
        local changeConnection=info.Changed and info.Changed:Connect(function() if current and not dialog.Destroyed then focus(current) end end)
        root.Destroying:Once(function()
            for _,connection in ipairs(connections) do connection:Disconnect() end
            resizeConnection:Disconnect()
            if changeConnection then changeConnection:Disconnect() end
            if self.ActiveBrowser and self.ActiveBrowser.Dialog==dialog then self.ActiveBrowser=nil end
        end)
        resize()
        self.ActiveBrowser={Dialog=dialog,Rows=rows,Checks=checks,Categories=categoryButtons,Search=search,Focus=focus,Activate=activate,SetSelected=select,Action=actionButton,Draft=draft,Root=root}
        return dialog
    end
    return self
end
return Interface
