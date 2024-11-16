local Mode = {}
Mode.register = function(mode) TriggerEvent("modeController:registerMode", mode) end
Mode.unregister = function(mode) TriggerEvent("modeController:unregisterMode", mode) end
Mode.activate = function(mode) TriggerEvent("modeController:activateMode", mode) end
Mode.deactivate = function(mode) TriggerEvent("modeController:deactivateMode", mode) end
Mode.toggle = function(mode) TriggerEvent("modeController:toggleMode", mode) end
Mode.isActive = function(mode) return exports.da_lib:isModeActive(mode) end
Mode.isPrimary = function(mode) return exports.da_lib:isModePrimary(mode) end
Mode.activateMCP = function(mode) TriggerEvent("modeController:activateMCP", mode) end
-- Mode.deactivateMCP = function() TriggerEvent("modeController:deactivateMCP") end

_ENV.da_mode = Mode

-- Mode Control Passthrough
local MCP = { active = false }

MCP.activate = function(mcpData)
    mcpData = mcpData or {}
    if MCP.active then return end
    MCP.active = true
    local exitKey = mcpData.key
    local activate = mcpData.activate
    local deactivate = mcpData.deactivate
    if exitKey then da_control.waitForRelease(exitKey) end
    if activate then activate() end
    while MCP.active do
        if exitKey and (
            IsControlJustReleased(0, exitKey) == 1 or
            IsDisabledControlJustReleased(0, exitKey) == 1
        ) then
            break
        end
        Citizen.Wait(0)
    end
    if deactivate then deactivate() end
    MCP.active = false
end
MCP.deactivate = function() MCP.active = false end

_ENV.da_mcp = MCP
