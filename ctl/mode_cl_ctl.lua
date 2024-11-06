local Mode = {}
local Active = nil
local AllActive = {}
local ControlMap = {}
local ControlTypes = {
    "pressed", "justPressed",
    "released", "justReleased",
    "longPressed", "quickPressed",
}

local ControlCacheKeyMap = {
    pressed = {},
    justPressed = {},
    released = {},
    justReleased = {},
    longPressed = {},
    quickPressed = {},
}
local ControlCacheMap = {
    pressed = {},
    justPressed = {},
    released = {},
    justReleased = {},
    longPressed = {},
    quickPressed = {},
}

local SetFocus = function(mode)
    if mode == nil or not Mode[mode] then
        log.error("Invalid mode: " .. tostring(mode))
        return
    end

    local focusKeyboard = Mode[mode].default.focusKeyboard
    local focusCursor = Mode[mode].default.focusCursor
    local keepFocus = Mode[mode].default.keepFocus
    local passthrough = Mode[mode].passthrough.enabled

    if passthrough then
        log.debug("Passthrough mode " .. mode)
        if Mode[mode].passthrough.focusKeyboard ~= nil then
            focusKeyboard = Mode[mode].passthrough.focusKeyboard
        end
        if Mode[mode].passthrough.focusCursor ~= nil then
            focusCursor = Mode[mode].passthrough.focusCursor
        end
        if Mode[mode].passthrough.keepFocus ~= nil then
            keepFocus = Mode[mode].passthrough.keepFocus
        end
    end

    if Mode[mode].modified.focusKeyboard ~= nil then
        focusKeyboard = Mode[mode].modified.focusKeyboard
    end
    if Mode[mode].modified.focusCursor ~= nil then
        focusCursor = Mode[mode].modified.focusCursor
    end
    if Mode[mode].modified.keepFocus ~= nil then
        keepFocus = Mode[mode].modified.keepFocus
    end

    Mode[mode].updateFn({
        focusKeyboard = focusKeyboard,
        focusCursor = focusCursor,
        keepFocus = keepFocus,
    })
end

local SetPassthrough = function(mode)
    if not Mode[mode] then return; end
    local passthrough = Mode[mode].passthrough.enabled ~= nil and Mode[mode].passthrough.enabled or false
    local passthroughKey = Mode[mode].passthroughKey
    local passthroughCb = Mode[mode].passthroughCb
    local passthroughFn = Mode[mode].passthroughFn

    if passthroughFn ~= nil then
        passthroughFn(passthrough, passthroughKey, passthroughCb)
    end
end

local Update = function(mode, data)
    if not Mode[mode] then return; end
    if not AllActive[mode] and not data.inactive then return; end

    if Mode[mode].updateFn then
        Mode[mode].updateFn(data)
    end
end

local UpdateActive = function()
    log.debug("mode_cl_ctl:UpdateActive", Active)
    local prevMode = Active
    if not AllActive[Active] then Active = nil end
    if next(AllActive) == nil then
        log.spam("No active modes.")
        if prevMode ~= nil then
            log.spam("Resetting last mode '" .. prevMode .. "'")
            Update(prevMode, {
                inactive = true,
                focusKeyboard = false,
                focusCursor = false,
                keepFocus = false,
                passthrough = false,
            })
            da_mode.reset(prevMode)
        end
        return
    end

    local highestMode = Active
    local highestPriority = highestMode and Mode[highestMode].priority or 0

    for mode in pairs(AllActive) do
        if Mode[mode].priority > highestPriority then
            highestMode = mode
            highestPriority = Mode[mode].priority
        end
    end

    Active = highestMode
    log.spam("Updating Active Mode " .. (Active ~= nil and Active or "none"))
    SetFocus(Active)
    SetPassthrough(Active)
end

local New = function(mode, data)
    log.debug("mode_cl_ctl:New", mode)
    if Mode[mode] then
        log.warn("Overwriting previously defined mode: " .. mode)
    end
    Mode[mode] = data
    if not Mode[mode].modified then Mode[mode].modified = {} end
    if not Mode[mode].passthrough then Mode[mode].passthrough = {} end
    if not Mode[mode].passthrough.enabled then
        Mode[mode].passthrough.enabled = false
    end
    log.spam("Mode created: " .. mode)
    if Mode[mode].controlMap then
        log.spam("Loading control map for mode: " .. mode)
        ModeLoadControlMap(mode, Mode[mode].controlMap)
    end
end

local Start = function(mode)
    log.debug("mode_cl_ctl:Start", mode, log.line(2))
    if not Mode[mode] then
        log.warn("Invalid mode: " .. mode)
        return
    end
    if AllActive[mode] then return; end
    AllActive[mode] = true
    if Mode[mode].startFn then
        Mode[mode].startFn()
    end
    UpdateActive()
end

local Stop = function(mode)
    log.debug("mode_cl_ctl:Stop", mode, log.line(2))
    if not Mode[mode] then
        log.warn("Invalid mode: " .. mode)
        return
    end
    if not AllActive[mode] then return; end
    AllActive[mode] = nil
    if Mode[mode].stopFn then
        Mode[mode].stopFn()
    end
    UpdateActive()
end

local Toggle = function(mode)
    log.spam("mode_cl_ctl:Toggle", mode, log.line(2))
    if not Mode[mode] then
        log.warn("Invalid mode: " .. mode)
        return
    end
    if not AllActive[mode] then
        Start(mode)
    else
        Stop(mode)
    end
end

local Set = function(mode, data)
    log.spam("mode_cl_ctl:Modify", mode, log.line(2))
    mode = mode or data.mode

    if not Mode[mode] then
        log.error(("Invalid mode '%s'"):format(mode))
        return
    end

    if data.requireActive and not AllActive[mode] then
        return
    end

    if data.add or data.start then
        Start(mode)
    end

    if data.remove or data.stop then
        Stop(mode)
    end

    if data.focusKeyboard ~= nil then
        if Mode[mode].focusKeyboard ~= data.focusKeyboard then
            Mode[mode].modified.focusKeyboard = data.focusKeyboard
        else
            Mode[mode].modified.focusKeyboard = nil
        end
    end

    if data.focusCursor ~= nil then
        if Mode[mode].focusCursor ~= data.focusCursor then
            Mode[mode].modified.focusCursor = data.focusCursor
        else
            Mode[mode].modified.focusCursor = nil
        end
    end

    if data.keepFocus ~= nil then
        if Mode[mode].keepFocus ~= data.keepFocus then
            Mode[mode].modified.keepFocus = data.keepFocus
        else
            Mode[mode].modified.keepFocus = nil
        end
    end

    if data.passthrough ~= nil then
        log.debug("Set: check passthrough not nil", data.passthrough, Mode[mode].passthrough.enabled)
        if Mode[mode].passthrough.enabled ~= data.passthrough then
            Mode[mode].passthrough.enabled = data.passthrough
            log.debug("Setting passthrough mode: " .. mode, data.passthrough)
            SetPassthrough(mode)
        else
            Mode[mode].passthrough.enabled = nil
        end
    end

    UpdateActive()
end

local Reset = function(mode)
    log.spam("mode_cl_ctl:Reset", mode, log.line(2))
    if not Mode[mode] then
        log.warn("Invalid mode: " .. mode)
        return
    end
    Mode[mode].modified = {}
    Mode[mode].passthrough.enabled = false
    UpdateActive()
end

local Passthrough = function(mode, enabled)
    log.spam("mode_cl_ctl:Passthrough", mode, log.line(2))
    if not Mode[mode] then
        log.warn("Invalid mode: " .. mode)
        return
    end
    if not AllActive[mode] then return; end
    Mode[mode].passthrough.enabled = enabled
    SetPassthrough(mode)
end

AddEventHandler("da_mode:new", function(mode, data) New(mode, data) end)
AddEventHandler("da_mode:start", function(mode) Start(mode) end)
AddEventHandler("da_mode:stop", function(mode) Stop(mode) end)
AddEventHandler("da_mode:toggle", function(mode) Toggle(mode) end)
AddEventHandler("da_mode:update", function(mode) Update(mode) end)
AddEventHandler("da_mode:set", function(mode, data) Set(mode, data) end)
AddEventHandler("da_mode:reset", function(mode) Reset(mode) end)
AddEventHandler("da_mode:passthrough", function(mode, enabled) Passthrough(mode, enabled) end)
exports("isActive", function(mode) return AllActive[mode] ~= nil end)
exports("isPrimary", function(mode) return Active == mode end)
exports("isPassthrough", function(mode) return AllActive[mode] ~= nil and Mode[mode].passthrough.enabled end)

function CheckControl(interact, controlCache)
    if interact.active and AllActive[interact.active] == nil then return; end
    if interact.primary and Active ~= interact.primary then return; end
    if interact.modifier then
        for modifier, value in pairs(interact.modifier) do
            local modifierPressed = controlCache.pressed[modifier] == true
            if modifierPressed ~= value then return end
        end
    end
    if interact.fn then
        interact.fn()
    end
end

local ThreadActive = false
function StartControlThread()
    log.debug("Starting control thread", ThreadActive)
    if ThreadActive then return; end
    ThreadActive = true
    Citizen.CreateThread(function()
        while ThreadActive do
            -- Gather control states based on ControlCacheMap
            local controlCache = {
                pressed = da_control.isPressed(ControlCacheMap.pressed),
                justPressed = da_control.isJustPressed(ControlCacheMap.justPressed),
                released = da_control.isReleased(ControlCacheMap.released),
                justReleased = da_control.isJustReleased(ControlCacheMap.justReleased),
                -- longPressed = da_control.isLongPressed(ControlCacheMap.longPressed),
                -- quickPressed = da_control.trackShortPress(ControlCacheMap.quickPressed)
            }

            -- Disable game control keys
            for key in pairs(ControlCacheKeyMap.disabled) do
                DisableControlAction(0, key, true)
            end

            -- Check for pressed keys and trigger callbacks
            for _, controlType in ipairs(ControlTypes) do
                if controlCache[controlType] ~= nil and next(controlCache[controlType]) then
                    for key, state in pairs(controlCache[controlType]) do
                        if state then
                            if ControlCacheKeyMap[controlType][key] then
                                for _, interact in ipairs(ControlCacheKeyMap[controlType][key]) do
                                    CheckControl(interact, controlCache)
                                end
                            end
                        end
                    end
                end
            end

            if ControlCacheKeyMap.disablePlayerFiring then
                DisablePlayerFiring(PlayerPedId(), true)
            end
            Citizen.Wait(0)
        end
    end)
end

function StopControlThread()
    ThreadActive = false
end


local function LoadControlCache()
    local controlCacheMap = {}
    for _, controlType in ipairs(ControlTypes) do
        local uniqueKeys = {}
        controlCacheMap[controlType] = {}
        -- Load modifiers
        if controlType == "pressed" then
            table.insert(controlCacheMap[controlType], "Ctrl")
            uniqueKeys["Ctrl"] = true
            table.insert(controlCacheMap[controlType], "Shift")
            uniqueKeys["Shift"] = true
            table.insert(controlCacheMap[controlType], "Alt")
            uniqueKeys["Alt"] = true
        end
        for key, _ in pairs(ControlCacheKeyMap[controlType]) do
            if not uniqueKeys[key] then
                table.insert(controlCacheMap[controlType], key)
                uniqueKeys[key] = true
            end
        end
    end
    return controlCacheMap
end

local function ReloadControlCache()
    local uniqueDisabledKeys = {}
    ControlCacheKeyMap = {
        disablePlayerFiring = false,
        disabled = {},
        pressed = {},
        justPressed = {},
        released = {},
        justReleased = {},
        longPressed = {},
        quickPressed = {},
    }
    for _, cmap in pairs(ControlMap) do
        if cmap.disablePlayerFiring then
            ControlCacheKeyMap.disablePlayerFiring = true
        end
        for _, keyMap in ipairs(cmap) do
            for _, controlType in ipairs(ControlTypes) do
                if keyMap[controlType] then
                    if not ControlCacheKeyMap[controlType][keyMap.key] then
                        ControlCacheKeyMap[controlType][keyMap.key] = {}
                    end
                    table.insert(ControlCacheKeyMap[controlType][keyMap.key], keyMap[controlType])
                    if not uniqueDisabledKeys[keyMap.key] then
                        ControlCacheKeyMap.disabled[keyMap.key] = true
                        uniqueDisabledKeys[keyMap.key] = true
                    end
                end
            end
        end
    end
    ControlCacheMap = LoadControlCache()
end

function ModeLoadControlMap(id, cmap)
    ControlMap[id] = cmap
    ReloadControlCache()
    StartControlThread()
end

function ModeRemoveControlMap(id)
    ControlMap[id] = nil
    ReloadControlCache()
end

RegisterCommand("getControlMaps", function(source, args, rawCommand)
    log.debug(ControlMap)
    log.debug(ControlCacheKeyMap)
end, false)

cli.add_cmd("mode", { desc = "Object commands" })
cli.add_subcmd("mode", "list", {
    desc = "List modes",
    fn = function()
        local mode_desc = ""
        mode_desc = mode_desc .. "Modes:"
        for mode in pairs(AllActive) do
            mode_desc = mode_desc .. "\n  " .. mode
        end
    end,
})
cli.add_subcmd("mode", "active", {
    desc = "List active mode",
    fn = function()
        log.info("Active Mode: " .. Active ~= nil and Active or "none")
    end,
})

cli.add_subcmd("mode", "control", { desc = "Control commands", })
cli.add_subcmd("mode control", "get", {
    desc = "Show control maps",
    opt = { ["mode"] = { desc = "Name of the mode", } },
    fn = function(args)
        if args.mode then
            log.info(ControlMap[args.mode])
            return
        end
        log.info(ControlMap)
    end,
})

-- NUI would have to be resource specific
-- cli.add_cmd("nui", { desc = "NUI commands", })
-- cli.add_subcmd("nui", "focus", { desc = "Modify NUI controller focus.", })
-- cli.add_subcmd("nui focus", "cursor", {
--     desc = "Set cursor and keyboard NUI focus [on/off]",
--     args = { "cursor", "keyboard" },
--     fn = function(args)
--         local focusCursor = args.cursor == "on"
--         local focusKeyboard = args.keyboard == "on"
--         log.debug(focusKeyboard, focusCursor)
--         SetNuiFocus(focusKeyboard, focusCursor)
--     end,
-- })
