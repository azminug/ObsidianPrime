-- Damped spring integrator. A render connection exists only while springs move.
local Motion = {}
function Motion.new()
    local run = game:GetService("RunService")
    local active, connection = {}, nil
    local self = { Reduced = false }
    local function components(value)
        local kind = typeof(value)
        if kind == "UDim2" then return {value.X.Scale,value.X.Offset,value.Y.Scale,value.Y.Offset},kind end
        if kind == "Color3" then return {value.R,value.G,value.B},kind end
        if kind == "Vector2" then return {value.X,value.Y},kind end
        assert(kind == "number", "Unsupported spring property: " .. kind)
        return {value},kind
    end
    local function compose(values,kind)
        if kind == "UDim2" then return UDim2.new(unpack(values)) end
        if kind == "Color3" then return Color3.new(math.clamp(values[1],0,1),math.clamp(values[2],0,1),math.clamp(values[3],0,1)) end
        if kind == "Vector2" then return Vector2.new(unpack(values)) end
        return values[1]
    end
    function self:Cancel(object) active[object] = nil end
    function self:To(object, goals, speed, damping, complete)
        if self.Reduced then
            active[object] = nil
            for key,value in pairs(goals) do object[key] = value end
            if complete then complete() end
            return
        end
        local entry = active[object] or {properties={}}
        entry.complete = complete
        entry.speed, entry.damping = speed or 24, damping or 0.88
        for key,value in pairs(goals) do
            local target,kind = components(value)
            local property = entry.properties[key]
            if not property then
                local current = components(object[key])
                property = {value=current, velocity={},kind=kind}
                for index in ipairs(current) do property.velocity[index]=0 end
                entry.properties[key]=property
            end
            property.target=target
        end
        active[object]=entry
        if connection then return end
        connection=run.RenderStepped:Connect(function(dt)
            local remaining=math.min(dt,0.1)
            while remaining > 0 do
                local step=math.min(remaining,1/120);remaining=remaining-step
                for object,item in pairs(active) do
                    if not object.Parent then active[object]=nil;continue end
                    local settled=true
                    for key,property in pairs(item.properties) do
                        for i,target in ipairs(property.target) do
                            local error=target-property.value[i]
                            property.velocity[i]=property.velocity[i]+(error*item.speed^2-2*item.damping*item.speed*property.velocity[i])*step
                            property.value[i]=property.value[i]+property.velocity[i]*step
                            if math.abs(error)>0.0005 or math.abs(property.velocity[i])>0.005 then settled=false end
                        end
                        object[key]=compose(property.value,property.kind)
                    end
                    if settled then
                        active[object]=nil
                        for key,property in pairs(item.properties) do object[key]=compose(property.target,property.kind) end
                        if item.complete then task.defer(item.complete) end
                    end
                end
            end
            if not next(active) then connection:Disconnect();connection=nil end
        end)
    end
    function self:SetReduced(value)
        self.Reduced=value == true
        if not self.Reduced then return end
        local callbacks={}
        for object,item in pairs(active) do
            if object.Parent then for key,p in pairs(item.properties) do object[key]=compose(p.target,p.kind) end end
            if item.complete then callbacks[#callbacks+1]=item.complete end
        end
        table.clear(active)
        if connection then connection:Disconnect();connection=nil end
        for _,fn in ipairs(callbacks) do fn() end
    end
    function self:Destroy()
        table.clear(active)
        if connection then connection:Disconnect();connection=nil end
    end
    return self
end
return Motion
