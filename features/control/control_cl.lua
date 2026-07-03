local DefaultLongPressMS = 300
local ControlPressed = {}

local Control = { keyHash = {}, keys = {} }
local Passthrough = {}

Control.waitForRelease = function(keys, timeout)
    timeout = timeout or 10000 -- Default wait is 10 seconds
    if keys == nil then
        keys = {}
    elseif type(keys) == "number" then
        keys = { keys }
    end
    local waitTime = GetGameTimer() + timeout
    local released = false
    while GetGameTimer() < waitTime do
        Citizen.Wait(0)
        released = true
        for _, key in ipairs(keys) do
            if IsControlPressed(0, key) == 1 or IsDisabledControlPressed(0, key) == 1 then
                released = false
                DrawScreenText("Release "..key, 0.95, 0.97, {r=80, g=193, b=238, a=255})
                break;
            end
        end
        if released then return true; end
    end
    log.debug("Timed out waiting for key release")
    return false
end

Control.isPressed = function(controls)
    controls = controls or {}
    local controlPressed = {}

    for _, key in ipairs(controls) do
        local keyMap = dat.keyHash[key]
        if keyMap then
            controlPressed[key] = IsControlPressed(0, keyMap) == 1
                or IsDisabledControlPressed(0, keyMap) == 1
        end
    end

    return controlPressed
end

Control.isJustPressed = function(controls)
    controls = controls or {}
    local controlJustPressed = {}

    for _, key in ipairs(controls) do
        local keyMap = dat.keyHash[key]
        if keyMap then
            controlJustPressed[key] = IsControlJustPressed(0, keyMap) == 1
                or IsDisabledControlJustPressed(0, keyMap) == 1
        end
    end

    return controlJustPressed
end

Control.isReleased = function(controls)
    controls = controls or {}
    local controlReleased = {}

    for _, key in ipairs(controls) do
        local keyMap = dat.keyHash[key]
        if keyMap then
            controlReleased[key] = IsControlReleased(0, keyMap) == 1
        end
    end
    return controlReleased
end

Control.isJustReleased = function(controls)
    controls = controls or {}
    local controlJustReleased = {}

    for _, key in ipairs(controls) do
        local keyMap = dat.keyHash[key]
        if keyMap then
            controlJustReleased[key] = IsControlJustReleased(0, keyMap) == 1
                or IsDisabledControlJustReleased(0, keyMap) == 1
        end
    end

    return controlJustReleased
end

Control.isLongPressed = function(key, ms)
    local pressed = Control.isPressed({key})
    local justPressed = Control.isJustPressed({key})
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

Control.trackLongPress = function(key, holdCallback, ms)
    ms = ms or DefaultLongPressMS
    Citizen.CreateThread(function()
        local deadline = GetGameTimer() + ms
        while GetGameTimer() < deadline do
            if not Control.isPressed({key})[key] then
                return
            end
            Citizen.Wait(0)
        end
        if holdCallback then holdCallback(); end
    end)
end

Control.trackShortPress = function(key, releaseCallback, ms)
    ms = ms or DefaultLongPressMS
    local keyPressedTimeout = GetGameTimer() + ms

    Citizen.CreateThread(function()
        while true do
            if keyPressedTimeout then
                if GetGameTimer() > keyPressedTimeout then
                    return
                end
            end

            local controlPressed = Control.isPressed({key})
            local controlJustReleased = Control.isJustReleased({key})

            if controlJustReleased[key] then
                if releaseCallback then releaseCallback(); end
                return
            end

            if not controlPressed[key] then
                return
            end

            Citizen.Wait(0)
        end
    end)
end

function Passthrough:isActive()
    return self and self.active or false
end

-- lazy.pollPassthrough = function() log.debug("Active passthrough poll") end

function Passthrough:start(haltKey, callback)
    log.spam("Passthrough started")
    if self.active then return; end
    self.haltKey = haltKey
    self.active = true
    if self.haltKey then
        da_control.waitForRelease(self.haltKey)
    end
    Citizen.CreateThread(function()
        while self.active do
            -- lazy(3000).pollPassthrough()
            Citizen.Wait(0)
            if self.haltKey then
                if IsDisabledControlJustReleased(0, self.haltKey) then break; end
            end
        end
        log.spam("Passthrough thread exit")
        if callback then callback(); end
        self.active = false
    end)
end

function Passthrough:stop()
    log.debug("Passthrough stopped")
    self.active = false
end

function Passthrough:set(active, haltKey, callback)
    if active then
        self:start(haltKey, callback)
    else
        self:stop()
    end
end

function Passthrough:toggle(haltKey, callback)
    if self.active then
        self:stop()
    else
        self:start(haltKey, callback)
    end
end

_ENV.da_control = Control
_ENV.da_controlpass = Passthrough
