-- Requires da_lib/lib/net_cl.lua
local GameTimeOffset = nil

local function epoch()
    local gameTime = math.floor(GetGameTimer() / 1000)
    if not GameTimeOffset then
        local epoch = TriggerBlockingServerEvent("da_lib.getEpoch", 2000)
        GameTimeOffset = epoch - gameTime
        if not GameTimeOffset then return 0; end
    end
    return GameTimeOffset + gameTime
end

_ENV.epoch = epoch
