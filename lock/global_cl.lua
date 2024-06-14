--- Copyright © 2024 Joshua Nelson

---Request a global lock from the server, if a lock is held the id will be
---stored in a GlobalState variable so that the status of the asset can be
---checked by any client locally.
---@param id string asset id for lock
---@param lockTimeout integer time to wait for lock
---@param callbackTimeout integer time to wait for callback
---@return unknown|nil
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

---Release a global lock if the client sill holds it.
---@param id any
---@param callbackTimeout any
---@return unknown|nil
function Lib.Lock.ReleaseGlobal(id, callbackTimeout)
    callbackTimeout = callbackTimeout or 2000
    return Lib.Net.BlockingCb('glb-lk',
        callbackTimeout,
        id, -- unique lock id
        false, -- false means release lock
        nil
    )
end
