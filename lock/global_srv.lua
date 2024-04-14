--- Copyright © 2024 Joshua Nelson

local Lock = {}
local Config = {
    DefaultTimeout = 2 * 60, -- 2 mins
    LockIdFmt = "glb-lk:%s",
    GarbageCollectInterval = 5 * 60, -- 5 mins
    GarbageCollected = os.time(),
}

Lib.Net.RegisterServerCb("glb-lk",
    function(source, id, requestLock, timeout)
        local src = source
        local lockId = Config.LockIdFmt:format(id)
        local currentTime = os.time()
        local success = ModifyLock(src, lockId, requestLock, timeout, currentTime)
        if currentTime > Config.GarbageCollected + Config.GarbageCollectInterval then
            _collectGarbage(currentTime)
        end
        return success
    end
)

function _getLock(id) return GlobalState[id] or Lock[id]; end

function _lock(src, id, timeout, currentTime)
    Lib.Log.Debug(("^3[glb-lk] ^2lock ^7src=%s id=%s timeout=%s"):format(src, id, timeout))
    timeout = timeout and (timeout/1000) + currentTime or Config.DefaultTimeout + currentTime
    GlobalState[id] = {
        source = src,
        timeout = timeout,
    }
    Lock[id] = { -- Use Lock since GlobalState sometimes isnt instant
        source = src,
        timeout = timeout,
    }
end

function _unlock(id)
    Lib.Log.Debug(("^3[glb-lk] ^5release ^7id=%s"):format(id))
    GlobalState[id] = nil
    Lock[id] = nil
end

function _hasLock(src, lock, currentTime)
    return not lock or lock.source == src or lock.timeout <= currentTime
end

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

function _collectGarbage(currentTime)
    for id in pairs(Lock) do
        if _hasLock(-1, GlobalState[id], currentTime) then _unlock(id); end
    end
end
