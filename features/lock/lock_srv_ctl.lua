-- Requires da_lib/lib/net_cl.lua

local DefaultTimeout = 2500
local Lock = {}

-- Exclusive Lock --
local function _lock(owner, id, timeout, currentTime)
    -- timeout is a duration in ms; convert to seconds and add to now (os.time is seconds).
    timeout = tonumber(timeout) and (tonumber(timeout)/1000) or DefaultTimeout
    Lock[id] = {
        owner = owner,
        timeout = timeout + currentTime,
    }
end

local function _unlock(id)
    Lock[id] = nil
end

local function _try_lock(owner, lock, currentTime, ltype)
    return not lock or (lock.type == ltype and (lock.owner == owner or lock.timeout <= currentTime))
end

local function xlock(owner, id, timeout)
    local t = os.time()
    if _try_lock(owner, Lock[id], t, nil) then
        _lock(owner, id, timeout, t)
        return true
    end
    return false
end

local function xunlock(owner, id)
    local t = os.time()
    if _try_lock(owner, Lock[id], t, nil) then
        _unlock(id)
        return true
    end
    return false
end

-- Blocking-event handlers receive the source as their first arg (net_srv calls
-- handler(src, ...)); the lock owner is supplied explicitly by the caller.
RegisterBlockingServerEvent("da_lib.xlock", function(src, owner, id, timeout)
    return xlock(owner, id, timeout)
end)

RegisterBlockingServerEvent("da_lib.xunlock", function(src, owner, id)
    return xunlock(owner, id)
end)

exports("xlock", xlock)
exports("xunlock", xunlock)


-- Exclusive Global Lock --
local function _gl_lock(owner, id, timeout, currentTime)
    timeout = tonumber(timeout) and (tonumber(timeout)/1000) or DefaultTimeout
    Lock[id] = {
        owner = owner,
        timeout = timeout + currentTime,
        type = "gl_lock",
    }
    GlobalState[id] = {
        owner = owner,
        timeout = timeout + currentTime
    }
end

local function _gl_unlock(id)
    Lock[id] = nil
    GlobalState[id] = nil
end

local function gl_xlock(owner, id, timeout)
    local t = os.time()
    if _try_lock(owner, Lock[id], t, "gl_lock") then
        _gl_lock(owner, id, timeout, t)
        return true
    end
    return false
end

local function gl_xunlock(owner, id)
    local t = os.time()
    if _try_lock(owner, Lock[id], t, "gl_lock") then
        _gl_unlock(id)
        return true
    end
    return false
end

RegisterBlockingServerEvent("da_lib.gl_xlock", function(src, owner, id, timeout)
    return gl_xlock(owner, id, timeout)
end)

RegisterBlockingServerEvent("da_lib.gl_xunlock", function(src, owner, id)
    return gl_xunlock(owner, id)
end)

exports("gl_xlock", gl_xlock)
exports("gl_xunlock", gl_xunlock)
