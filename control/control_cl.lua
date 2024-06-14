local passthroughThreadActive = false

---Disable all RDR2 controls while a thread runs or unless a pass through key iis pressed
---@param state boolean whether to enable or disable the passthrough thread
Lib.Control.Passthrough = function(state)
    if passthroughThreadActive == state then return; end
    passthroughThreadActive = state

    if passthroughThreadActive then
        Citizen.CreateThread(function()
            while passthroughThreadActive do
                Citizen.Wait(0)
                if not IsDisabledControlPressed(0, `INPUT_AIM`, true) then
                    DisableAllControlActions(0)
                end
            end
            passthroughThreadActive = false
        end)
    end
end
