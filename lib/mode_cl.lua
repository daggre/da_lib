local Mode = {}

local ValidateMode = function(mode, data)
    assert(type(mode) == "string", "Mode must be a string")

    assert(type(data) == "table", "Data must be a table")
    assert(data.priority == nil or type(data.priority) == "number", "Priority must be a number")
    assert(data.focusKeyboard == nil or type(data.focusKeyboard) == "boolean", "FocusKeyboard must be a boolean")
    assert(data.focusCursor == nil or type(data.focusCursor) == "boolean", "FocusCursor must be a boolean")
    assert(data.keepFocus == nil or type(data.keepFocus) == "boolean", "KeepFocus must be a boolean")

    return true
end

Mode.new = function(id, data)
    local modeData = {
        priority = data.priority or 0,
        default = data.default,
        startFn = data.startFn,
        stopFn = data.stopFn,
        updateFn = data.updateFn,
        passthrough = data.passthrough,
        passthroughKey = data.passthroughKey or 0,
        passthroughFn = data.passthroughFn,
        passthroughCb = data.passthroughCb,
        controlMap = data.controlMap,
    }

    if not ValidateMode(id, modeData) then return; end

    TriggerEvent("da_mode:new", id, modeData)
end

Mode.start = function(mode) TriggerEvent("da_mode:start", mode) end
Mode.stop = function(mode) TriggerEvent("da_mode:stop", mode) end
Mode.toggle = function(mode) TriggerEvent("da_mode:toggle", mode); log.debug("Toggling", mode, log.line(2)) end
Mode.set = function(mode, data) TriggerEvent("da_mode:set", mode, data) end
Mode.reset = function(mode) TriggerEvent("da_mode:reset", mode) end
Mode.passthrough = function(mode, enabled) TriggerEvent("da_mode:passthrough", mode, enabled) end
Mode.isActive = function(mode) return exports.da_lib:isActive(mode) end
Mode.isPrimary = function(mode) return exports.da_lib:isPrimary(mode) end
Mode.isPassthrough = function(mode) return exports.da_lib:isPassthrough(mode) end

_ENV.da_mode = Mode
