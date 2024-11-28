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
            IsControlJustPressed(0, exitKey) == 1 or
            IsDisabledControlJustPressed(0, exitKey) == 1
        ) then
            break
        end
        -- DrawScreenText("MCP Active", 0.95, 0.95, {r=80, g=193, b=238, a=255})

        Citizen.Wait(0)
    end
    if deactivate then deactivate() end
    MCP.active = false
end
MCP.deactivate = function() MCP.active = false end

_ENV.da_mcp = MCP

local Mode = {}
Mode.register = function(mode)
    mode.resource = GetCurrentResourceName()
    TriggerEvent("modeController:registerMode", mode)
end
Mode.unregister = function(mode) TriggerEvent("modeController:unregisterMode", mode) end
Mode.activate = function(mode) TriggerEvent("modeController:activateMode", mode) end
Mode.deactivate = function(mode) TriggerEvent("modeController:deactivateMode", mode) end
Mode.toggle = function(mode) TriggerEvent("modeController:toggleMode", mode) end
Mode.activateMCP = function(mode) TriggerEvent("modeController:activateMCP", mode) end
-- Mode.deactivateMCP = function() TriggerEvent("modeController:deactivateMCP") end

Mode.isActive = function(mode) return exports.da_lib:isModeActive(mode) end
Mode.isPrimary = function(mode) return exports.da_lib:isModePrimary(mode) end
_ENV.da_mode = Mode
