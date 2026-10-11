-- ObsidianPrime composition helpers. Uses native Ultra controls only.
-- This addon renders application state; it never starts gameplay workers.
local Imperium = {}

function Imperium.new(Library, Window)
    local self = { Library = Library, Window = Window, Alive = true, CompactLayout = false }
    local palette = {
        Off = "FontColor", Running = "Success", Waiting = "Warning", Error = "Error", Paused = "Warning",
    }
    Library:OnUnload(function() self.Alive = false end)

    -- Initial layout responds to the available viewport, including narrow desktop windows.
    local camera = workspace.CurrentCamera
    self.CompactLayout = Library.IsMobile or (camera and camera.ViewportSize.X < 760) or false

    function self:AddTab(name, icon)
        return Window:AddTab({ Name = name, Icon = icon, SingleColumn = self.CompactLayout })
    end

    function self:SetReducedMotion(enabled)
        if not self.Alive then return end
        Library.ReducedMotion = enabled
        if self.Appearance then self.Appearance:SetReducedMotion(enabled) end
        local motion = not enabled
        Window:SetAnimations({ ToggleWindow = false, TabSwitch = motion, Groupbox = false,
            GroupboxCollapse = motion, Dropdown = motion, KeyPicker = motion,
            SubTabUnderline = motion, SidebarSubTabs = motion })
    end

    function self:AddActivity(groupbox, id, title)
        local owner = self
        local row = groupbox:AddStatusLabel(id, { Items = { { Text = title, Status = "Off" } }, MaxHeight = 32 })
        local detail = groupbox:AddLabel("Belum diaktifkan.", true)
        local activity = { State = "Off", Detail = "Belum diaktifkan." }
        function activity:SetState(state, message)
            assert(palette[state], "Unknown activity state: " .. tostring(state))
            if not owner.Alive then return end
            message = message or ""
            if activity.State ~= state then
                local color = Library.NotificationTypeColors[palette[state]] or Library.Scheme[palette[state]]
                row:SetItems({ { Text = title, Status = state, StatusColor = color } })
                activity.State = state
            end
            if activity.Detail ~= message then
                detail:SetText(message)
                activity.Detail = message
            end
        end
        return activity
    end

    function self:SetSessionStatus(text)
        if not self.Alive or self.SessionStatus == text then return end
        self.SessionStatus = text
        Window:SetMinimizedSubtitle(text)
    end
    return self
end

return Imperium
