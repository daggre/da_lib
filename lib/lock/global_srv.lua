--- Copyright © 2024 Joshua Nelson

local Lock = {}
local Config = {
    DefaultTimeout = 2 * 60, -- 2 mins
    LockIdFmt = "glb-lk:%s",
    GarbageCollectInterval = 5 * 60, -- 5 mins
    GarbageCollected = os.time(),
}

---Register a cliet to server callback for requesting a global lock
Lib.Net.RegisterServerCb("glb-lk",
    function(source, id, requestLock, timeout)
        local src = source
        local lockId = Config.LockIdFmt:format(id)
        local currentTime = os.time()
        local success = ModifyLock(src, lockId, requestLock, timeout, currentTime)

        -- Check if garbage needs to be collected
        if currentTime > Config.GarbageCollected + Config.GarbageCollectInterval then
            Citizen.CreateThread(function() _collectGarbage(currentTime) end)
        end

        return success
    end
)

---Check if a lock is being held
---@param id string The asset id
---@return table|nil lockState Return the assed id lock state
function _getLock(id) return GlobalState[id] or Lock[id]; end

---Lock the asset
---@param src integer The src id of the client locking the asset
---@param id string The asset id
---@param timeout integer|nil The length of time in ms to hold the lock
---@param currentTime integer The current epoch time
function _lock(src, id, timeout, currentTime)
    Lib.Log.Debug(("^3[glb-lk] ^2lock ^7src=%s id=%s timeout=%s"):format(src, id, timeout))
    timeout = timeout and (timeout/1000) + currentTime or Config.DefaultTimeout + currentTime
    -- Set the GlobalState variable of the locked asset
    GlobalState[id] = {
        source = src,
        timeout = timeout,
    }
    -- Track the lock locally also, since GlobalState can be slow and lead to race conditions
    Lock[id] = {
        source = src,
        timeout = timeout,
    }
end

---Unlock the asset
---@param id string The asset id
function _unlock(id)
    Lib.Log.Debug(("^3[glb-lk] ^5release ^7id=%s"):format(id))
    GlobalState[id] = nil
    Lock[id] = nil
end

function _hasLock(src, lock, currentTime)
    return not lock or lock.source == src or lock.timeout <= currentTime
end

---Process a lock request and modify the lock based on the success and report
---the action/result to the caller.
---@param source integer The calling client id
---@param id string The asset id
---@param requestLock boolean|nil True if this is a lock request, otherwise process it as a release request
---@param timeout integer|nil The time in ms to hold the lock
---@param currentTime integer The current epoch
---@return boolean success Return true if the modification succeeded or false if the lock is currently held by some other client
function ModifyLock(source, id, requestLock, timeout, currentTime)
    local src = source

    if not _hasLock(src, _getLock(id), currentTime) then
        Lib.Log.Debug(("^3[glb-lk] ^1deny ^7src=%s id=%s"):format(src, id))
        return false
    end

    if requestLock then
        _lock(src, id, timeout, currentTime)
    else
        _unlock(id)
    end

    return true
end

---Iterate all locks and remove timed out locks
---@param currentTime integer The current epoch
function _collectGarbage(currentTime)
    for id in pairs(Lock) do
        if _hasLock(-1, GlobalState[id], currentTime) then _unlock(id); end
    end
end
