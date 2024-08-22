local Passthrough = {}

function Passthrough:IsActive()
    return self.active
end

function Passthrough:Start(haltKey, callback)
    if self.active then return; end
    self.haltKey = haltKey
    self.active = true
    Lib.Control.WaitForKeyRelease(self.haltKey)
    Citizen.CreateThread(function()
        while self.active do
            Citizen.Wait(0)
            if IsDisabledControlJustReleased(0, self.haltKey) then break; end
        end
        if callback then callback(); end
        self.active = false
    end)
end

function Passthrough:Stop()
    self.active = false
end

Lib.Control.PassthroughIsActive = function()
    return Passthrough:IsActive()
end

Lib.Control.Passthrough = function(active, haltKey, callback)
    if active then
        Passthrough:Start(haltKey, callback)
    else
        Passthrough:Stop()
    end
end
