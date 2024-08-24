ActiveMap = {}
ControlCacheMap = {}
ControlThread = {}

-- Control thread that continuously evaluates key mappings
function ControlThread:Start()
    self.active = true
    Citizen.CreateThread(function()
        while self.active do
            -- Gather control states based on ControlCacheMap
            local controlCache = {
                pressed = Lib.Control.GetPressed(ControlCacheMap.pressed),
                justPressed = Lib.Control.GetJustPressed(ControlCacheMap.justPressed),
                released = Lib.Control.GetReleased(ControlCacheMap.released),
                justReleased = Lib.Control.GetJustReleased(ControlCacheMap.justReleased),
                longPressed = Lib.Control.GetLongPressed(ControlCacheMap.longPressed),
                quickPressed = Lib.Control.GetQuickPressed(ControlCacheMap.quickPressed)
            }

            -- Evaluate key mappings against the control states
            for _, keyMap in ipairs(ActiveMap) do
                if EvaluateKeyMap(keyMap, controlCache) then
                    keyMap.callback()
                end
            end
            Citizen.Wait(0)
        end
    end)
end

function ControlThread:Stop()
    self.active = false
end

-- Function to evaluate key mappings against control states
function EvaluateKeyMap(keyMap, controlCache)
    if keyMap.pressed and not controlCache.pressed[keyMap.control] then
        return false
    end
    if keyMap.justPressed and not controlCache.justPressed[keyMap.control] then
        return false
    end
    if keyMap.released and not controlCache.released[keyMap.control] then
        return false
    end
    if keyMap.justReleased and not controlCache.justReleased[keyMap.control] then
        return false
    end
    if keyMap.longPressed and not controlCache.longPressed[keyMap.control] then
        return false
    end
    if keyMap.quickPressed and not controlCache.quickPressed[keyMap.control] then
        return false
    end
    return true
end

-- Function to load a control map with various configurations
function LoadControlMap(controlMap)
    ActiveMap = controlMap

    local pressed = {}
    local justPressed = {}
    local released = {}
    local justReleased = {}
    local longPressed = {}
    local quickPressed = {}

    -- Populate the control cache with control configurations
    for _, keyMap in ipairs(controlMap) do
        if keyMap.pressed then
            table.insert(pressed, keyMap.control)
        end
        if keyMap.justPressed then
            table.insert(justPressed, keyMap.control)
        end
        if keyMap.released then
            table.insert(released, keyMap.control)
        end
        if keyMap.justReleased then
            table.insert(justReleased, keyMap.control)
        end
        if keyMap.longPressed then
            table.insert(longPressed, keyMap.control)
        end
        if keyMap.quickPressed then
            table.insert(quickPressed, keyMap.control)
        end
    end

    -- Cache the control states
    ControlCacheMap = {
        pressed = pressed,
        justPressed = justPressed,
        released = released,
        justReleased = justReleased,
        longPressed = longPressed,
        quickPressed = quickPressed
    }
end
