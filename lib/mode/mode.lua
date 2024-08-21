Mode = {}
ActiveMode = nil
local AllActiveModes = {}

local SetMode = function(mode)
    if mode == nil or not Mode[mode] then
        Lib.Log.Error(("Invalid mode '%s'"):format(mode))
        return
    end

    local focusKeyboard = Mode[mode].default.focusKeyboard
    if Mode[mode].modified.focusKeyboard ~= nil then focusKeyboard = Mode[mode].modified.focusKeyboard end
    local focusCursor = Mode[mode].default.focusCursor
    if Mode[mode].modified.focusCursor ~= nil then focusCursor = Mode[mode].modified.focusCursor end
    local keepFocus = Mode[mode].default.keepFocus
    if Mode[mode].modified.keepFocus ~= nil then keepFocus = Mode[mode].modified.keepFocus end
    local passthrough = Mode[mode].default.passthrough
    if Mode[mode].modified.passthrough ~= nil then passthrough = Mode[mode].modified.passthrough end
    local passthroughHaltKey = Mode[mode].default.passthroughHaltKey
    local passthroughCallback = Mode[mode].default.passthroughCallback


    Mode[mode].default.updateFn({
        focusKeyboard = focusKeyboard,
        focusCursor = focusCursor,
        keepFocus = keepFocus,
        passthrough = passthrough,
    })

    Lib.Control.Passthrough(passthrough, passthroughHaltKey, passthroughCallback)
    Lib.Log.Debug(("Setting mode '%s' key=%s mouse=%s keep=%s passthrough=%s"):format(
        mode, focusKeyboard, focusCursor, keepFocus, passthrough))
end

Lib.Mode.New = function(mode, priority, data)
    if Mode[mode] ~= nil then
        Lib.Log.Warn(("Updating mode '%s'"):format(mode))
    end

    Mode[mode] = {}
    Mode[mode].modified = {}
    Mode[mode].priority = priority or 0

    data = data or {}
    Mode[mode].default = data
    Mode[mode].default.passthrough = false
    Mode[mode].default.passthroughHaltKey = data.passthroughHaltKey or Lib.Control.Map.c
    Mode[mode].default.updateFn = data.updateFn

    ModeCheck(mode, Mode[mode])
    Lib.Log.Debug(("Mode '%s' created"):format(mode))
end

Lib.Mode.Add = function(mode)
    if AllActiveModes[mode] then return; end
    Lib.Log.Debug(("Adding mode %s"):format(mode))
    if not Mode[mode] then
        Lib.Log.Error(("Invalid mode '%s'"):format(mode))
        return
    end
    AllActiveModes[mode] = true
    if Mode[mode].default.initFn then
        Mode[mode].default.initFn()
    end
    Lib.Mode.Update()
end

Lib.Mode.Remove = function(mode)
    if not AllActiveModes[mode] then return; end
    Lib.Log.Debug(("Removing mode %s"):format(mode))
    if AllActiveModes[mode] and Mode[mode].default.exitFn then
        Mode[mode].default.exitFn()
    end
    Mode[mode].default.updateFn({
        focusKeyboard = false,
        focusCursor = false,
        keepFocus = false,
        passthrough = false,
    })
    AllActiveModes[mode] = nil
    Lib.Mode.Update()
end

Lib.Mode.Toggle = function(mode)
    if AllActiveModes[mode] then
        Lib.Mode.Remove(mode)
    else
        Lib.Mode.Add(mode)
    end
end

Lib.Mode.Modify = function(mode, data)
    mode = mode or data.mode

    if not Mode[mode] then
        Lib.Log.Error(("Invalid mode '%s'"):format(mode))
        return
    end

    if data.requireActive and not AllActiveModes[mode] then
        return
    end

    if data.add then
        Lib.Mode.Add(mode)
    end

    if data.remove then
        Lib.Mode.Remove(mode)
    end

    if data.focusKeyboard ~= nil then
        if Mode[mode].default.focusKeyboard ~= data.focusKeyboard then
            Mode[mode].modified.focusKeyboard = data.focusKeyboard
        else
            Mode[mode].modified.focusKeyboard = nil
        end
    end

    if data.focusCursor ~= nil then
        if Mode[mode].default.focusCursor ~= data.focusCursor then
            Mode[mode].modified.focusCursor = data.focusCursor
        else
            Mode[mode].modified.focusCursor = nil
        end
    end

    if data.keepFocus ~= nil then
        if Mode[mode].default.keepFocus ~= data.keepFocus then
            Mode[mode].modified.keepFocus = data.keepFocus
        else
            Mode[mode].modified.keepFocus = nil
        end
    end

    if data.passthrough ~= nil then
        if Mode[mode].default.passthrough ~= data.passthrough then
            Mode[mode].modified.passthrough = data.passthrough
            if Mode[mode].default.passthroughFn ~= nil then
                Mode[mode].default.passthroughFn()
            end
        else
            Mode[mode].modified.passthrough = nil
        end
    end

    Lib.Mode.Update()
end

Lib.Mode.Reset = function(mode)
    if Mode[mode] then
        Mode[mode].modified = {}
        Lib.Mode.Update()
    end
end

Lib.Mode.IsActive = function(mode)
    return AllActiveModes[mode]
end

Lib.Mode.Update = function()
    Lib.Log.Debug("Updating active mode")
    local activeMode = nil
    local activePriority = 0
    for mode in pairs(AllActiveModes) do
        local modePrio = Mode[mode].priority
         if modePrio > activePriority then
            activeMode = mode
            activePriority = modePrio
        end
    end
    ActiveMode = activeMode
    if activeMode then
        SetMode(activeMode)
    end
end

RegisterNUICallback('modifyMode', function(data, cb)
    Lib.Mode.Modify(data.mode, data)
    cb(true)
end)

RegisterNUICallback('endPassthrough', function(data, cb)
    Lib.Control.Passthrough(false)
    cb(true)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        Lib.Control.Passthrough(false)
    end
end)

