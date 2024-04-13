--- Copyright © 2024 Joshua Nelson


function Lib.Lock.Global(id, lockTimeout, callbackTimeout)
    lockTimeout = lockTimeout or 10000
    callbackTimeout = callbackTimeout or 2000
    return Lib.Net.BlockingCb('glb-lk',
        callbackTimeout,
        id, -- unique lock id
        true, -- request lock
        lockTimeout
    )
end

function Lib.Lock.ReleaseGlobal(id, callbackTimeout)
    callbackTimeout = callbackTimeout or 2000
    return Lib.Net.BlockingCb('glb-lk',
        callbackTimeout,
        id, -- unique lock id
        false, -- false means release lock
        nil
    )
end
