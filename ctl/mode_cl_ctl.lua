-- Mode Controller
log.debug("Initializing Mode Controller...")

local Control = {
    keyHash = {
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
    },
    events = { "pressed", "justPressed", "released", "justReleased" }
}

local ModeController = {
    eventMap = {},
    keyEventMap = {
        pressed = {},
        justPressed = {},
        released = {},
        justReleased = {},
        modifiers = {},
    },
    primaryMode = nil,
    activeModes = {},
    modes = {},
}

function ModeController:primaryModeName()
    local primary = self.primaryMode
    return primary and primary.name or nil
end

function ModeController:registerMode(modeDefinition)
    if not modeDefinition then log.error("Mode definition required") return; end
    local modeName = modeDefinition.name
    if not modeName then log.error("Mode must have a name") return; end
    self.modes[modeName] = modeDefinition
    log.spam("Mode registered: " .. modeName)
    self:cacheInputEventChecks()
end

function ModeController:unregisterMode(modeName)
    self.modes[modeName] = nil
    log.spam("Mode unregistered: " .. modeName)
end

function ModeController:activateMode(modeName)
    local mode = self.modes[modeName]
    if not mode then log.error("Mode not found: " .. modeName) return; end
    if mode.active then return; end

    mode.active = true
    table.insert(self.activeModes, mode)
    self:sortActiveModes()

    if mode.onActivate then mode.onActivate(); end
    log.debug("Mode activated: " .. modeName)
    self:cacheInputEventChecks()
end

function ModeController:deactivateMode(modeName)
    local mode = self.modes[modeName]
    if not mode then log.error("Mode not found: " .. modeName) return; end
    if not mode.active then return; end
    mode.active = false
    for i, m in ipairs(self.activeModes) do
        if m.name == modeName then
            table.remove(self.activeModes, i)
            if mode.onDeactivate then mode.onDeactivate(); end
            log.debug("Mode deactivated: " .. modeName)
            self:sortActiveModes()
            self:cacheInputEventChecks()
            break
        end
    end
end

function ModeController:sortActiveModes()
    table.sort(self.activeModes, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    if self.primaryMode ~= self.activeModes[1] then
        log.debug("Primary mode changed: " ..
            (self.primaryMode and self.primaryMode.name or "nil") .. " -> " ..
            (self.activeModes[1] and self.activeModes[1].name or "nil"))
        if self.primaryMode and self.primaryMode.onLosePrimary then
            self.primaryMode.onLosePrimary()
        end
        self.primaryMode = self.activeModes[1]
        if self.primaryMode and self.primaryMode.onPrimary then
            self.primaryMode.onPrimary()
        end
    end
end

function ModeController:getModesSort()
    local sortedModes = {}

    for _, mode in pairs(self.modes) do
        table.insert(sortedModes, mode)
    end

    -- Sort modes active to inactive, priority descending
    table.sort(sortedModes, function(a, b)
        if a.active == b.active then
            return (a.priority or 0) > (b.priority or 0)
        else
            return a.active and not b.active
        end
    end)

    return sortedModes
end

function ModeController:cacheInputEventChecks()
    local eventMap = {}
    local keyEventMap = {
        pressed = {},
        justPressed = {},
        released = {},
        justReleased = {},
        modifiers = {},
    }

    for _, mode in ipairs(self:getModesSort()) do
        if mode.keymaps then
            for key, keymap in pairs(mode.keymaps) do
                if not eventMap[key] then eventMap[key] = {} end -- Initialize
                for _, event in ipairs({"pressed","justPressed","released","justReleased"}) do
                    if keymap[event] then
                        if not ( -- Check if the event meets requirements
                            (keymap[event].primary and mode.name ~= self:primaryModeName()) or
                            (keymap[event].active and not mode.active)
                        ) then
                            if not eventMap[key][event] then
                                eventMap[key][event] = {}
                            end
                            table.insert(eventMap[key][event], keymap[event])
                            keyEventMap[event][key] = true
                            -- Cache modifiers
                            if keymap[event].modifiers then
                                for modifier in pairs(keymap[event].modifiers) do
                                    keyEventMap.modifiers[modifier] = true
                                end
                            end
                        end
                    end
                end
                if not next(eventMap[key]) then eventMap[key] = nil end -- Uninitialize
            end
        end
    end

    self.eventMap = eventMap
    self.keyEventMap = keyEventMap
end

function ModeController:dispatchEvent(event)
    log.debug("Dispatching event", event.type, event)
    local eventMap = self.eventMap

    if not eventMap[event.key] or not eventMap[event.key][event.type] then
        log.warn("No event mapped for", event.type, event.key)
        return
    end
    for _, modeEvent in ipairs(eventMap[event.key][event.type]) do
        local fireEvent = true
        if modeEvent.modifiers then
            for mod, value in pairs(modeEvent.modifiers) do
                if event.mods[mod] ~= value then
                    fireEvent = false
                    break
                end
            end
        end
        if fireEvent then
            Citizen.CreateThread(function() modeEvent.fn(event)
            end)
            if modeEvent.consume then
                break
            end
        end
    end
end

function ModeController:collectEvents()
    while true do
        local keyEventMap = self.keyEventMap
        local modifiers = {}

        for k in pairs(keyEventMap.modifiers) do
            local keyHash = Control.keyHash[k]
            modifiers[k] = IsControlPressed(0, keyHash) == 1 or
                IsDisabledControlPressed(0, keyHash) == 1
        end

        for k in pairs(keyEventMap.pressed) do
            local keyHash = Control.keyHash[k]
            local dispatchEvent = IsControlPressed(0, keyHash) == 1 or
                IsDisabledControlPressed(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "pressed", mods = modifiers, })
            end
        end

        for k in pairs(keyEventMap.justPressed) do
            local keyHash = Control.keyHash[k]
            local dispatchEvent = IsControlJustPressed(0, keyHash) == 1 or
                IsDisabledControlJustPressed(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "justPressed", mods = modifiers, })
            end
        end

        for k in pairs(keyEventMap.released) do
            local keyHash = Control.keyHash[k]
            local dispatchEvent = IsControlReleased(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "released", mods = modifiers, })
            end
        end

        for k in pairs(keyEventMap.justReleased) do
            local keyHash = Control.keyHash[k]
            local dispatchEvent = IsControlJustReleased(0, keyHash) == 1 or
                IsDisabledControlJustReleased(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "justReleased", mods = modifiers, })
            end
        end

        Citizen.Wait(0)
    end
end

function ModeController:activateMCP(modeName)
    modeName = modeName or self:primaryModeName()
    local mode = self.modes[modeName]
    if not mode then log.error("Mode not found: " .. modeName) return; end

    if mode.activateMCP then
        mode.activateMCP()
    else
        log.error("Mode does not support MCP: " .. modeName)
    end
end

da_net.events({
    ["modeController:registerMode"] = function(...) ModeController:registerMode(...) end,
    ["modeController:unregisterMode"] = function(...) ModeController:unregisterMode(...) end,
    ["modeController:activateMode"] = function(...) ModeController:activateMode(...) end,
    ["modeController:deactivateMode"] = function(...) ModeController:deactivateMode(...) end,
    ["modeController:toggleMode"] = function(...)
        if ModeController.modes[...] then
            if ModeController.modes[...].active then
                ModeController:deactivateMode(...)
            else
                ModeController:activateMode(...)
            end
        end
    end,
    ["modeController:activateMCP"] = function(...) ModeController:activateMCP(...) end,
    -- ["modeController:deactivateMCP"] = function() da_mcp.deactivate() end,
    ["modeController:simulateEvent"] = function(...) ModeController:dispatchEvent(...) end,
})

exports("isModeActive", function(mode) return ModeController.modes[mode] and ModeController.modes[mode].active end)
exports("isModePrimary", function(mode) return ModeController:primaryModeName() == mode end)

cli.add_cmd("mode", { desc = "Object commands" })
cli.add_subcmd("mode", "primary", { desc = "List primary mode",
    fn = function() log.info(ModeController:primaryModeName()) end,
})
cli.add_subcmd("mode", "list", { desc = "List modes",
    opt = { ["mode"] = { desc = "Name of the mode", } },
    fn = function() log.info(ModeController.modes) end,
})
cli.add_subcmd("mode", "active", { desc = "List active modes",
    fn = function() log.info(ModeController.activeModes) end,
})
cli.add_subcmd("mode", "control", { desc = "Control commands", })
cli.add_subcmd("mode control", "list", { desc = "Show control maps",
    opt = { ["mode"] = { desc = "Name of the mode", } },
    fn = function(args)
        for modeName, mode in pairs(ModeController.modes) do
            if not args.mode or args.mode == modeName then
                log.info(modeName, mode.keymaps)
            end
        end
    end,
})

cli.add_subcmd("mode control", "cache", { desc = "Control cache", })
cli.add_subcmd("mode control cache", "keymap", { desc = "Control cache keymap",
    fn = function() log.info(ModeController.keyEventMap) end,
})
-- cli.add_subcmd("mode control cache", "map", { desc = "Control cache map",
--     fn = function() log.info(ControlCacheMap) end,
-- })

Citizen.CreateThread(function() ModeController:collectEvents() end)

-- TODO: Add game mode and ability to register game mode keymaps from mode_cl
