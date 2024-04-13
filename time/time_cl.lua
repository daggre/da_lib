--- Copyright © 2024 Joshua Nelson

local EpochOffset = nil

function Lib.Time.Epoch()
    if not EpochOffset then
        EpochOffset = Lib.Net.BlockingCb('util:epoch', 3000)
        print("Set EpochOffset to", EpochOffset)
        if not EpochOffset then return 0; end
    end
    return EpochOffset + ( GetGameTimer() / 1000 )
end
