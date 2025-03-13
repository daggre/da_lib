local function xlock(owner, id, timeout)
    return TriggerBlockingServerEvent("da_lib.xlock", 2000, owner, id, timeout)
end

local function xunlock(owner, id)
    return TriggerBlockingServerEvent("da_lib.xunlock", 2000, owner, id)
end

_ENV.xlock = xlock
_ENV.xunlock = xunlock

local function gl_xlock(owner, id, timeout)
    return TriggerBlockingServerEvent("da_lib.gl_xlock", 2000, owner, id, timeout)
end

local function gl_xunlock(owner, id)
    return TriggerBlockingServerEvent("da_lib.gl_xunlock", 2000, owner, id)
end

_ENV.gl_xlock = gl_xlock
_ENV.gl_xunlock = gl_xunlock
