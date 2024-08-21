--- Copyright © 2024 Joshua Nelson

local EpochOffset = nil

---Get the current epoch time and calculate the offset for the game timer
---@return integer epoch The current epoch time
function Lib.Time.Epoch()
    -- If the EpochOffset has not been set, get it from the server
    if not EpochOffset then
        -- The epoch offset is roughly the epoch when the game started
        EpochOffset = Lib.Net.BlockingCb('util:epoch', 3000) - math.floor(GetGameTimer() / 1000)
        Lib.Log.Debug("Set EpochOffset to", EpochOffset)
        if not EpochOffset then return 0; end
    end
    -- Calculate the current epoch by adding seconds since game started to the epoch offset
    return EpochOffset + math.floor( GetGameTimer() / 1000 )
end
