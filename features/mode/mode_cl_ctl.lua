-- Mode Controller
log.debug("Initializing Mode Controller...")

local GameKeymaps = {}
local RegisterGameKeymap = function(key, map)
    if not GameKeymaps[key] then GameKeymaps[key] = {} end
    table.insert(GameKeymaps[key], map)
end

-- Every callback the controller holds — mode lifecycle hooks, keymap fns, keymap conditions — was
-- authored in ANOTHER resource and arrived here as a function reference. Calling one crosses the
-- script-host boundary, and when the callee throws, all that surfaces on this side is
--
--     SCRIPT ERROR: Execution of function reference in script host failed:
--
-- attributed to da_lib, with no message and no stack. The real error, with its traceback, is logged
-- by the OWNING resource on the line above — but the da_lib line is the one that reads like the
-- culprit, so the hunt starts in the wrong resource.
--
-- Worse, the throw propagates: an onActivate that dies takes out the rest of activateMode with it,
-- so the mode ends up flagged active with its keymaps never cached — active but deaf.
--
-- So every crossing goes through here. The error is caught, labelled with WHICH callback died and
-- WHICH resource owns it, and the controller carries on with its own bookkeeping intact.
local function callHook(what, owner, fn, ...)
    local ok, err = pcall(fn, ...)
    if ok then return true; end
    log.error(("%s failed (owner: %s): %s"):format(what, owner or "unknown", tostring(err)))
    log.error("^ the real error and its stack were logged by '" .. tostring(owner or "unknown") ..
        "' just above this line")
    return false
end

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

function ModeController:assertModeFormat(m)
    assert(m.name ~= nil, "Mode missing name")
    assert(m.priority == nil or tonumber(m.priority), ("Failed to register mode '%s': Invalid priority"):format(m.name))
    if m.keymaps ~= nil then
        for _, km in ipairs(m.keymaps) do
            assert(type(km.key) == "string" and dat.keyHash[km.key] ~= nil, ("Failed to register mode '%s': Invalid keymap %s"):format(m.name, km))
            assert(type(km.event) == "string" and ModeController.keyEventMap[km.event] ~= nil, ("Failed to register mode '%s': Invalid key event %s"):format(m.name, km))
        end
    end
end

function ModeController:registerMode(modeDefinition)
    if not modeDefinition then log.error("Mode definition required") return; end
    local modeName = modeDefinition.name
    if not modeName then log.error("Mode must have a name") return; end
    ModeController:assertModeFormat(modeDefinition)
    self.modes[modeName] = modeDefinition
    log.debug("Mode registered: " .. modeName)
    self:cacheInputEventChecks()
end

function ModeController:unregisterMode(modeName)
    self.modes[modeName] = nil
    log.debug("Mode unregistered: " .. modeName)
    -- Symmetric with registerMode. Without it an INACTIVE mode's keymaps outlived the mode itself
    -- in the dispatch cache — deactivateMode is what normally rebuilds, and it never ran.
    self:cacheInputEventChecks()
end

function ModeController:activateMode(modeName)
    local mode = self.modes[modeName]
    if not mode then log.error("Mode not found: " .. modeName) return; end
    if mode.active then return; end

    mode.active = true
    table.insert(self.activeModes, mode)
    self:sortActiveModes()

    if mode.onActivate then
        callHook(("mode '%s' onActivate"):format(modeName), mode.resource, mode.onActivate)
    end
    log.spam("Mode activated: " .. modeName)
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
            if mode.onDeactivate then
                callHook(("mode '%s' onDeactivate"):format(modeName), mode.resource, mode.onDeactivate)
            end
            log.spam("Mode deactivated: " .. modeName)
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
        log.spam("Primary mode changed: " ..
            (self.primaryMode and self.primaryMode.name or "nil") .. " -> " ..
            (self.activeModes[1] and self.activeModes[1].name or "nil"))
        if self.primaryMode and self.primaryMode.onLosePrimary then
            callHook(("mode '%s' onLosePrimary"):format(self.primaryMode.name),
                self.primaryMode.resource, self.primaryMode.onLosePrimary)
        end
        self.primaryMode = self.activeModes[1]
        if self.primaryMode and self.primaryMode.onPrimary then
            callHook(("mode '%s' onPrimary"):format(self.primaryMode.name),
                self.primaryMode.resource, self.primaryMode.onPrimary)
        end
    end
end

local GAME_EVENTS = { "pressed", "justPressed", "released", "justReleased" }

-- Game keymaps are stored keyed by key name, each value a list of maps shaped
-- { pressed = fn, justPressed = fn, ... }. Expand them into the same flat
-- { key, event, fn, ... } shape every other keymap uses, so the dispatch cache
-- (which iterates ipairs(mode.keymaps)) picks them up. Tagged active = true so
-- they ride the Game pseudo-mode's active flag — i.e. a disableGame mode suppresses them.
local function expandGameKeymaps()
    local out = {}
    for key, maps in pairs(GameKeymaps) do
        for _, map in ipairs(maps) do
            for _, event in ipairs(GAME_EVENTS) do
                if map[event] then
                    out[#out + 1] = {
                        key = key,
                        event = event,
                        fn = map[event],
                        active = true,
                        consume = map.consume,
                        modifiers = map.modifiers,
                        resource = map.resource,
                    }
                end
            end
        end
    end
    return out
end

function ModeController:getModesSort()
    local sortedModes = {}
    local gameModeActive = true

    for _, mode in pairs(self.modes) do
        -- Only an *active* disableGame mode suppresses the baseline Game keymaps;
        -- a merely-registered (inactive) one must not, or game keys would never fire.
        if mode.active and mode.disableGame then gameModeActive = false end
        table.insert(sortedModes, mode)
    end
    table.insert(sortedModes, {
        priority = 0,
        name = "Game",
        active = gameModeActive,
        keymaps = expandGameKeymaps(),
    })

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
            for _, keymap in ipairs(mode.keymaps) do
                local key = keymap.key
                local event = keymap.event
                if not eventMap[key] then eventMap[key] = {} end -- Initialize
                if not ( -- Check if the event meets requirements
                    (keymap.primary and mode.name ~= self:primaryModeName()) or
                    (keymap.active and not mode.active)
                ) then
                    if not eventMap[key][event] then
                        eventMap[key][event] = {}
                    end
                    -- A shallow record rather than the keymap itself: dispatch only ever reads
                    -- these three fields, and the record is where the blame goes. A game keymap
                    -- carries the resource that registered it; a mode's own keymaps belong to
                    -- whoever registered the mode.
                    table.insert(eventMap[key][event], {
                        fn        = keymap.fn,
                        modifiers = keymap.modifiers,
                        consume   = keymap.consume,
                        owner     = keymap.resource or mode.resource,
                        mode      = mode.name,
                    })
                    keyEventMap[event][key] = true
                    -- Cache modifiers
                    if keymap.modifiers then
                        for modifier in pairs(keymap.modifiers) do
                            keyEventMap.modifiers[modifier] = true
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
    log.spam("Dispatching event", event.type, event)
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
            Citizen.CreateThread(function()
                callHook(("keymap '%s' %s (mode '%s')"):format(event.key, event.type, modeEvent.mode),
                    modeEvent.owner, modeEvent.fn, event)
            end)
            if modeEvent.consume then
                break
            end
        end
    end
end

function ModeController:dispatchEvents(events)
    local keyEventMap = self.keyEventMap
    local modifiers = { ctrl = false, shift = false, alt = false, }

    for k in pairs(keyEventMap.modifiers) do
        modifiers[k] = events.modifiers[k] == true
    end

    for k in pairs(keyEventMap.pressed) do
        local dispatchEvent = events.pressed[k]
        if dispatchEvent then
            log.spam("Dispatching pressed event", k, modifiers)
            self:dispatchEvent({ key = k, type = "pressed", mods = modifiers, })
        end
    end

    for k in pairs(keyEventMap.justPressed) do
        local dispatchEvent = events.justPressed[k]
        if dispatchEvent then
            log.spam("Dispatching justPressed event", k, modifiers)
            self:dispatchEvent({ key = k, type = "justPressed", mods = modifiers, })
        end
    end

    for k in pairs(keyEventMap.released) do
        local dispatchEvent = events.released[k]
        if dispatchEvent then
            self:dispatchEvent({ key = k, type = "released", mods = modifiers, })
        end
    end

    for k in pairs(keyEventMap.justReleased) do
        local dispatchEvent = events.justReleased[k]
        if dispatchEvent then
            self:dispatchEvent({ key = k, type = "justReleased", mods = modifiers, })
        end
    end
end

function ModeController:collectEvents()
    while true do
        local keyEventMap = self.keyEventMap
        local eventMap = self.eventMap
        local modifiers = { ctrl = false, shift = false, alt = false, }

        for k in pairs(eventMap) do
            -- TODO: Add disable flag in eventMap
            local keyHash = dat.keyHash[k]
            DisableControlAction(0, keyHash, true)
        end

        for k in pairs(keyEventMap.modifiers) do
            local keyHash = dat.keyHash[k]
            modifiers[k] = IsControlPressed(0, keyHash) == 1 or
                IsDisabledControlPressed(0, keyHash) == 1
        end

        for k in pairs(keyEventMap.pressed) do
            local keyHash = dat.keyHash[k]
            local dispatchEvent = IsControlPressed(0, keyHash) == 1 or
                IsDisabledControlPressed(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "pressed", mods = modifiers, })
            end
        end

        for k in pairs(keyEventMap.justPressed) do
            local keyHash = dat.keyHash[k]
            local dispatchEvent = IsControlJustPressed(0, keyHash) == 1 or
                IsDisabledControlJustPressed(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "justPressed", mods = modifiers, })
            end
        end

        for k in pairs(keyEventMap.released) do
            local keyHash = dat.keyHash[k]
            local dispatchEvent = IsControlReleased(0, keyHash) == 1
            if dispatchEvent then
                self:dispatchEvent({ key = k, type = "released", mods = modifiers, })
            end
        end

        for k in pairs(keyEventMap.justReleased) do
            local keyHash = dat.keyHash[k]
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
    if not mode then log.error("Mode not found: " .. modeName) return false; end

    if mode.activateMCP then
        return mode.activateMCP()
    else
        log.error("Mode does not support MCP: " .. modeName)
    end
    return false
end

-- Consumer-facing interface. The mode facade (mode_cl.lua) calls these exports;
-- the caller is captured with GetInvokingResource() so resource-stop cleanup works.
exports("registerMode", function(mode)
    if mode then mode.resource = GetInvokingResource() end
    ModeController:registerMode(mode)
end)
exports("unregisterMode", function(modeName) ModeController:unregisterMode(modeName) end)
exports("activateMode", function(modeName) ModeController:activateMode(modeName) end)
exports("deactivateMode", function(modeName) ModeController:deactivateMode(modeName) end)
exports("toggleMode", function(modeName)
    local mode = ModeController.modes[modeName]
    if mode then
        if mode.active then
            ModeController:deactivateMode(modeName)
        else
            ModeController:activateMode(modeName)
        end
    end
end)
exports("dispatchEvents", function(events) ModeController:dispatchEvents(events) end)
exports("simulateEvent", function(event) ModeController:dispatchEvent(event) end)
exports("addGameKey", function(key, map)
    if not dat.keyHash[key] then log.error("Key not found: " .. key) return; end
    if not map then log.error("Map required") return; end
    if not map.pressed and not map.justPressed and not map.released and not map.justReleased then
        log.error("Map must have at least one event")
        return
    end
    map.resource = GetInvokingResource()
    RegisterGameKeymap(key, map)
    ModeController:cacheInputEventChecks()
end)

exports("isModeActive", function(mode) return ModeController.modes[mode] and ModeController.modes[mode].active end)
exports("isModePrimary", function(mode) return ModeController:primaryModeName() == mode end)
exports("activateMCP", function(mode) return ModeController:activateMCP(mode) end)

-- Read-only inspection surface. These let other resources (e.g. da_audit) see the
-- controller's state without reaching into it; until now enumeration lived only in
-- the CLI commands below. Each returns a fresh table so callers can't mutate state.
exports("primaryMode", function() return ModeController:primaryModeName() end)
exports("modeList", function()
    local primary = ModeController:primaryModeName()
    local out = {}
    for name, mode in pairs(ModeController.modes) do
        out[#out + 1] = {
            name = name,
            active = mode.active == true,
            primary = name == primary,
            priority = mode.priority or 0,
            disableGame = mode.disableGame == true,
            resource = mode.resource,
        }
    end
    return out
end)
exports("activeModeList", function()
    local out = {}
    for _, mode in ipairs(ModeController.activeModes) do out[#out + 1] = mode.name end
    return out
end)
exports("keymapCache", function()
    local kc = ModeController.keyEventMap
    local function copySet(set)
        local t = {}
        for k in pairs(set or {}) do t[k] = true end
        return t
    end
    return {
        pressed = copySet(kc.pressed),
        justPressed = copySet(kc.justPressed),
        released = copySet(kc.released),
        justReleased = copySet(kc.justReleased),
        modifiers = copySet(kc.modifiers),
    }
end)

-- Remove the game keymaps a resource registered (symmetric with the onResourceStop
-- cleanup below, but callable — e.g. for test teardown). Scoped to the invoking resource.
exports("clearGameKeys", function()
    local res = GetInvokingResource()
    for key, keymaps in pairs(GameKeymaps) do
        for i = #keymaps, 1, -1 do
            if keymaps[i].resource == res then table.remove(keymaps, i) end
        end
        if not next(keymaps) then GameKeymaps[key] = nil end
    end
    ModeController:cacheInputEventChecks()
end)

AddEventHandler("onResourceStop", function(resourceName)
    -- Remove any Game keymaps associated with resource.
    --
    -- BACKWARDS, like clearGameKeys above, and for the reason that export was written that way:
    -- table.remove slides every later element down one, so a forward ipairs walk then steps over
    -- whatever moved into the slot it just emptied. One keymap per key survived each stop —
    -- holding a function reference into a script host that no longer exists. Registering fresh
    -- ones on restart stacked a new pair on top of the corpse, and the next press dispatched it:
    --
    --     SCRIPT ERROR: Execution of function reference in script host failed:
    --
    -- with nothing before it, because there was no live code left to raise a Lua error. Clean on a
    -- cold boot, broken after a couple of restarts, and the resource named is never the one at
    -- fault. Any resource binding TWO maps to one key hit it (da_anims binds X twice — plain and
    -- ALT), and the survivor was un-droppable: the next stop skipped it the same way.
    for key, keymaps in pairs(GameKeymaps) do
        for i = #keymaps, 1, -1 do
            if keymaps[i].resource == resourceName then
                log.spam("Removing resource keymap", resourceName, key, keymaps[i])
                table.remove(keymaps, i)
            end
        end
        if not next(keymaps) then GameKeymaps[key] = nil end
    end
    -- Deactivate and unregister resource that stopped
    for modeName, mode in pairs(ModeController.modes) do
        if mode.resource == resourceName then
            if mode.active then
                log.warn("Resource stopped with active mode: " .. modeName)
                ModeController:deactivateMode(modeName)
            end
            log.spam("Unregistering mode: " .. modeName)
            ModeController:unregisterMode(modeName)
        end
    end

    -- The dispatch cache holds its OWN records, so dropping a keymap from the registry above
    -- changes nothing until the cache is rebuilt. Unconditional: deactivateMode rebuilds only
    -- when the mode was active, and a game keymap is not a mode at all.
    ModeController:cacheInputEventChecks()
end)

cli.add_cmd("mode", { desc = "Object commands" })
cli.add_subcmd("mode", "primary", { desc = "List primary mode",
    fn = function() log.info(ModeController:primaryModeName()) end,
})
cli.add_subcmd("mode", "list", { desc = "List modes",
    opt = { ["mode"] = { desc = "Name of the mode", } },
    fn = function(args)
        for modeName, mode in pairs(ModeController.modes) do
            if not args.mode or args.mode == modeName then
                log.info(mode.name, mode.active)
            end
        end
    end,
})
cli.add_subcmd("mode", "active", { desc = "List active modes",
    fn = function()
        for _, mode in ipairs(ModeController.activeModes) do
            log.info(mode.name)
        end
    end,
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
cli.add_subcmd("mode", "activate", { desc = "Activate mode",
    args = { "mode" },
    fn = function(args) ModeController:activateMode(args.mode) end,
})
cli.add_subcmd("mode", "deactivate", { desc = "Deactivate mode",
    args = { "mode" },
    fn = function(args) ModeController:deactivateMode(args.mode) end,
})

Citizen.CreateThread(function() ModeController:collectEvents() end)
