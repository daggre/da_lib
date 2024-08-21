ModeCheck = function(name, mode)
    Lib.Log.Debug(("Checking mode '%s'"):format(name))
    assert(mode.priority ~= nil, "Mode priority is required")
    assert(mode.default ~= nil and type(mode.default) == "table", "Mode default table is required")

    assert(mode.default.focusKeyboard ~= nil, "Mode default.focusKeyboard is required")
    assert(mode.default.focusCursor ~= nil, "Mode default.focusCursor is required")
    assert(mode.default.keepFocus ~= nil, "Mode default.keepFocus is required")
    assert(mode.default.passthrough ~= nil, "Mode default.passthrough is required")
    assert(mode.default.passthroughHaltKey ~= nil, "Mode default.passthroughHaltKey is required")
    assert(mode.default.updateFn ~= nil, "Mode default.updateFn is required")

    assert(mode.modified ~= nil and type(mode.modified) == "table", "Mode modified table is required")
end
