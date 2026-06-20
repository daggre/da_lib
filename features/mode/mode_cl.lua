-- Mode facade: the stateless stub each resource includes. Every method forwards
-- to the single Mode Controller in da_lib via exports. Carries no state itself.
local Mode = {}

Mode.register = function(mode) return exports.da_lib:registerMode(mode) end
Mode.unregister = function(mode) return exports.da_lib:unregisterMode(mode) end
Mode.activate = function(mode) return exports.da_lib:activateMode(mode) end
Mode.deactivate = function(mode) return exports.da_lib:deactivateMode(mode) end
Mode.toggle = function(mode) return exports.da_lib:toggleMode(mode) end
Mode.dispatchEvents = function(events) return exports.da_lib:dispatchEvents(events) end
Mode.simulateEvent = function(event) return exports.da_lib:simulateEvent(event) end
Mode.addGameKey = function(key, map) return exports.da_lib:addGameKey(key, map) end

Mode.isActive = function(mode) return exports.da_lib:isModeActive(mode) end
Mode.isPrimary = function(mode) return exports.da_lib:isModePrimary(mode) end
Mode.activateMCP = function(mode) return exports.da_lib:activateMCP(mode) end

-- Read-only inspection (used by da_audit and tests).
Mode.primary = function() return exports.da_lib:primaryMode() end
Mode.list = function() return exports.da_lib:modeList() end
Mode.activeList = function() return exports.da_lib:activeModeList() end
Mode.keymapCache = function() return exports.da_lib:keymapCache() end
Mode.clearGameKeys = function() return exports.da_lib:clearGameKeys() end

_ENV.da_mode = Mode
