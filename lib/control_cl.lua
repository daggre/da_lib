-- TODO: convert this to da_key
local DefaultLongPressMS = 300
local ControlPressed = {}

local Control = { keyHash = {} }
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
        local keyMap = Control.keyHash[key]
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
        local keyMap = Control.keyHash[key]
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
        local keyMap = Control.keyHash[key]
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
        local keyMap = Control.keyHash[key]
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

Control.trackShortPress = function(key, releaseCallback, ms)
    ms = ms or DefaultLongPressMS -- 100ms
    local keyPressedTimeout = GetGameTimer() + ms
    log.debug("Short Press started", key, keyPressedTimeout)

    Citizen.CreateThread(function()
        while true do
            if keyPressedTimeout then
                if GetGameTimer() > keyPressedTimeout then
                    log.debug("Long Pressed, exiting short press loop", key)
                    return
                end
            end

            local controlPressed = Control.isPressed({key})
            local controlJustReleased = Control.isJustReleased({key})

            if controlJustReleased[key] then
                log.debug("Short Pressed, exiting short press loop")
                if releaseCallback then releaseCallback(); end
                return
            end

            if not controlPressed[key] then
                log.debug("Key was released, exiting short press loop")
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

Control.keyHash = {
    ['1'] = `INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT`,
    ['2'] = `INPUT_SELECT_QUICKSELECT_DUALWIELD`,
    ['3'] = `INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT`,
    ['4'] = `INPUT_SELECT_QUICKSELECT_UNARMED`,
    ['5'] = `INPUT_SELECT_QUICKSELECT_MELEE_NO_UNARMED`,
    ['6'] = `INPUT_SELECT_QUICKSELECT_SECONDARY_LONGARM`,
    ['7'] = `INPUT_SELECT_QUICKSELECT_THROWN`,
    ['8'] = `INPUT_SELECT_QUICKSELECT_PRIMARY_LONGARM`,
    ['a'] = `INPUT_MOVE_LEFT_ONLY`,
    ['c'] = `INPUT_LOOK_BEHIND`,
    ['d'] = `INPUT_MOVE_RIGHT_ONLY`,
    ['e'] = `INPUT_DYNAMIC_SCENARIO`,
    ['f'] = `INPUT_CONTEXT_B`,
    ['g'] = `INPUT_INTERACT_ANIMAL`,
    ['h'] = `INPUT_WHISTLE`,
    ['q'] = `INPUT_FRONTEND_LB`,
    ['r'] = `INPUT_RELOAD`,
    ['s'] = `INPUT_MOVE_DOWN_ONLY`,
    ['v'] = `INPUT_NEXT_CAMERA`,
    ['w'] = `INPUT_MOVE_UP_ONLY`,
    ['x'] = `INPUT_SWITCH_SHOULDER`,
    ['z'] = `INPUT_GAME_MENU_TAB_LEFT_SECONDARY`,
    ['Crouch'] = `INPUT_DUCK`,
    ['Spacebar'] = `INPUT_JUMP`,
    [' '] = `INPUT_JUMP`,
    ['Alt'] = `INPUT_HUD_SPECIAL`,
    ['Shift'] = `INPUT_SPRINT`,
    ['Ctrl'] = `INPUT_FRONTEND_RUP`,
    ['MouseLR'] = `INPUT_LOOK_LR`,
    ['MouseUD'] = `INPUT_LOOK_UD`,
    ['MouseLeft'] = `INPUT_ATTACK`,
    ['MouseLeft2'] = `SKIPCUTSCENE`,
    ['MouseRight'] = `INPUT_AIM`,
    ['MouseScrollClick'] = `INPUT_PC_FREE_LOOK`,
    ['WheelUp'] = `INPUT_PREV_WEAPON`,
    ['WheelDown'] = `INPUT_NEXT_WEAPON`,
    [']'] = `INPUT_SNIPER_ZOOM_IN_ONLY`, -- Possible conflict with scroll up
    ['RightBracket'] = `INPUT_SNIPER_ZOOM_IN_ONLY`,
    ['Escape'] = `INPUT_GAME_MENU_CANCEL`, -- Conflict with Backspace
    ['Escape2'] = `INPUT_FRONTEND_RRIGHT`,
    ['Escape3'] = `INPUT_FRONTEND_PAUSE_ALTERNATE`,
}

_ENV.da_control = Control
_ENV.da_controlpass = Passthrough
