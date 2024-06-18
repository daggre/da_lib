local passthroughThreadActive = false
-- local passthroughKey = `INPUT_AIM`

---Disable all RDR2 controls while a thread runs or unless a pass through key
---is pressed @param state boolean whether to enable or disable the passthrough
---thread
Lib.Control.Passthrough = function(state)
    if passthroughThreadActive == state then return; end
    passthroughThreadActive = state

    if passthroughThreadActive then
        Citizen.CreateThread(function()
            Lib.Log.Debug("Passthrough thread started")
            Citizen.Wait(1000)
            while passthroughThreadActive do
                Citizen.Wait(0)
                -- if not IsDisabledControlPressed(0, passthroughKey, true) then
                --     break
                --     -- DisableAllControlActions(0)
                -- end
            end
            Lib.Log.Debug("Passthrough thread ended")
            passthroughThreadActive = false
        end)
    end
end
