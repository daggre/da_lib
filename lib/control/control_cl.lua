local DefaultLongPressMS = 100
local ControlPressed = {}

local Control = {}
Control.a = `INPUT_MOVE_LEFT_ONLY`
Control.c = 0x9959A6F0
Control.d = `INPUT_MOVE_RIGHT_ONLY`
Control.e = `INPUT_DYNAMIC_SCENARIO`
Control.f = `INPUT_CONTEXT_B`
Control.g = `INPUT_INTERACT_ANIMAL`
Control.h = 0x24978A28
Control.q = `INPUT_FRONTEND_LB`
Control.r = `INPUT_RELOAD`
Control.s = `INPUT_MOVE_DOWN_ONLY`
Control.v = `INPUT_NEXT_CAMERA`
Control.w = `INPUT_MOVE_UP_ONLY`
Control.x = `INPUT_SWITCH_SHOULDER`
Control.z = 0x26E9DC00
Control.Crouch = `INPUT_DUCK`
Control.Spacebar = `INPUT_JUMP`
Control[" "] = `INPUT_JUMP`
Control.Alt = `INPUT_PC_FREE_LOOK`
Control.Shift = `INPUT_SPRINT`
Control.Control = `INPUT_FRONTEND_RUP`
Control.MouseLR = `INPUT_LOOK_LR`
Control.MouseUD = `INPUT_LOOK_UD`
Control.MouseLeft = `INPUT_ATTACK`
Control.MouseLeft2 = `SKIPCUTSCENE`
Control.MouseRight = `INPUT_AIM`
Control.WheelUp = `INPUT_PREV_WEAPON`
Control.WheelDown = `INPUT_NEXT_WEAPON`
Control["]"] = 0xA5BDCD3C
Control.RightBracket = 0xA5BDCD3C
Control.Escape = 0x308588E6
Control.Escape2 = `INPUT_FRONTEND_RRIGHT`
Control.Escape3 = `INPUT_FRONTEND_PAUSE_ALTERNATE`

local passthroughThreadActive = false

Lib.Control.PassthroughIsActive = function()
    return passthroughThreadActive
end

---Wait for key(s) to be released
---@param keys table|number The key(s) to wait for release
---@param timeout number|nil The time to wait before returning
---@return boolean success If the key(s) released
Lib.Control.WaitForKeyRelease = function(keys, timeout)
    timeout = timeout or 10000 -- Default wait is 10 seconds
    if type(keys) == "number" then keys = { keys }; end
    local waitTime = GetGameTimer() + timeout
    local released = false
    while GetGameTimer() < waitTime do
        Citizen.Wait(0)
        released = true
        for _, key in ipairs(keys) do
            if IsControlPressed(0, key) or IsDisabledControlPressed(0, key) then
                released = false
                break;
            end
        end
        if released then return true; end
    end
    Lib.Log.Debug("Timed out waiting for key release")
    return false
end

---Disable all RDR2 controls while a thread runs or unless a pass through key
---is pressed @param state boolean whether to enable or disable the passthrough
---thread
Lib.Control.Passthrough = function(state, haltKey, callback)
    if passthroughThreadActive == state then return; end
    passthroughThreadActive = state

    if passthroughThreadActive then
        local waitTime = GetGameTimer() + 1000
        while IsDisabledControlPressed(0, haltKey, true) and GetGameTimer() < waitTime do
            -- Give the user a chance to release the key
            Citizen.Wait(0)
        end
        Citizen.CreateThread(function()
            Lib.Log.Debug("Passthrough thread started")
            while passthroughThreadActive do
                Citizen.Wait(0)
                if IsDisabledControlJustReleased(0, haltKey, true) then break; end
            end
            Lib.Log.Debug("Passthrough thread ended")
            if callback then callback(); end
            passthroughThreadActive = false
        end)
    end
end

Lib.Control.GetPressed = function(pressed)
    pressed = pressed or {}
    local getPressed = {}

    for _, key in ipairs(pressed) do
        if Control[key] then
            getPressed[key] = IsControlPressed(0, Control[key]) or IsDisabledControlPressed(0, Control[key])
        end
    end

    return getPressed
end

Lib.Control.GetJustPressed = function(justPressed)
    local getJustPressed = {}
    justPressed = justPressed or {}

    for _, key in ipairs(justPressed) do
        if Control[key] then
            getJustPressed[key] = IsControlJustPressed(0, Control[key]) or IsDisabledControlJustPressed(0, Control[key])
        end
    end

    return getJustPressed
end

Lib.Control.GetReleased = function(released)
    local getReleased = {}
    released = released or {}

    for _, key in ipairs(released) do
        if Control[key] then
            getReleased[key] = IsControlReleased(0, Control[key])
        end
    end
    return getReleased
end

Lib.Control.GetJustReleased = function(justReleased)
    local getJustReleased = {}
    justReleased = justReleased or {}

    for _, key in ipairs(justReleased) do
        if Control[key] then
            getJustReleased[key] = IsControlJustReleased(0, Control[key]) or IsDisabledControlJustReleased(0, Control[key])
        end
    end

    return getJustReleased
end

Lib.Control.IsLongPressed = function(key, ms)
    local pressed = Lib.Control.GetPressed({key})
    local justPressed = Lib.Control.GetJustPressed({key})
    ms = ms or DefaultLongPressMS

    if justPressed[key] then
        ControlPressed[key] = GetGameTimer()
        return false
    end
    if not pressed[key] then
        ControlPressed[key] = nil
        return false
    end

    return ControlPressed[key] and GetGameTimer() > ControlPressed[key] + ms
end

Lib.Control.ShortPress = function(key, releaseCallback, ms)
    ms = ms or DefaultLongPressMS -- 100ms
    local keyPressedTimeout = GetGameTimer() + ms
    Lib.Log.Debug("Short Press started", key, keyPressedTimeout)

    Citizen.CreateThread(function()
        while true do
            if keyPressedTimeout then
                if GetGameTimer() > keyPressedTimeout then
                    Lib.Log.Debug("Long Pressed, exiting short press loop", key)
                    return
                end
            end

            local pressed = Lib.Control.GetPressed({key})
            local justReleased = Lib.Control.GetJustReleased({key})

            if justReleased[key] then
                Lib.Log.Debug("Short Pressed, exiting short press loop")
                if releaseCallback then releaseCallback(); end
                return
            end

            if not pressed[key] then
                Lib.Log.Debug("Key was released, exiting short press loop")
                return
            end

            Citizen.Wait(0)
        end
    end)
end

Lib.Control.Map = Control
Lib.Control.Keys = ControlKeys
