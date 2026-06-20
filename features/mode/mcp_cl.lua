-- Mode Control Passthrough (MCP)
-- Runs a control loop on behalf of a mode until an exit key is pressed, calling
-- the mode's activate/deactivate callbacks around it. Mode-adjacent but independent
-- of the Mode Controller. Include only where modes run interactive control loops.
local MCP = { active = false }

MCP.activate = function(mcpData)
    mcpData = mcpData or {}
    if MCP.active then return true end
    MCP.active = true
    Citizen.CreateThread(function()
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
    end)
    return true
end
MCP.deactivate = function()
    MCP.active = false
    return MCP.active
end

_ENV.da_mcp = MCP
