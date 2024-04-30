local passthroughThreadActive = false
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
