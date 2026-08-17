local LoadAnimDict = function(dict, timeout)
    timeout = timeout or 200
    local cutoff = GetGameTimer() + timeout
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
        RequestAnimDict(dict)
        if GetGameTimer() > cutoff then
            return false
        end
    end
    return true
end

local anim = {}

-- Lua 5.4 keeps integers and floats apart, and the native invoker passes each one through as the
-- type it was given. A FLOAT parameter handed an integer is not the same number to the game: a
-- blendIn of `1` does not play the blend `1.0` plays, and nothing errors — it just looks wrong.
-- That's the whole reason `1.01` behaved and `1` didn't.
--
-- Everything reaching here has crossed a boundary that loses the distinction: NUI hands over JSON
-- (`1.0` encodes as `1`), a contenteditable field hands over the string "1", and `tonumber("1")`
-- returns an INTEGER. So a value is not trustworthy just because it was a float where it was
-- authored — it has to be re-floated at the call site.
--
-- `+ 0.0` is the house spelling for "this is a float" (see da_lib camera/object).
local flt = function(v, default)
    local n = tonumber(v)
    if n == nil then return default end
    return n + 0.0
end

-- The mirror case: durations, flags and bitfields are INTEGER parameters, and a UI field that
-- picked up a stray `.0` (or a computed millisecond value that came out float) is the same class of
-- silent mismatch in the other direction.
local int = function(v, default)
    local n = tonumber(v)
    if n == nil then return default end
    return math.tointeger(n) or math.tointeger(math.floor(n)) or default
end

-- opts (all optional): {
--   blendIn  = 3.0,   -- blend-in speed
--   blendOut = 0.5,   -- blend-out speed
--   duration = -1,    -- ms, -1 = play to natural end
--   flags    = 0,     -- animation flags bitfield
--   rate     = 0,     -- playback rate
--   ikFlags  = 0,     -- IK flags bitfield
--   filter   = false, -- task filter name (e.g. "headandneckonly_filter")
-- }
anim.ped = function(entity, dict, name, opts)
    opts = opts or {}
    local blendIn  = flt(opts.blendIn,  3.0)
    local blendOut = flt(opts.blendOut, 0.5)
    local duration = int(opts.duration, -1)
    local flags    = int(opts.flags,     0)
    local rate     = flt(opts.rate,      0.0)
    local ikFlags  = int(opts.ikFlags,   0)
    local filter   = opts.filter ~= nil and opts.filter or false
    local p8, p10, p12 = false, false, false

    log.spam("Playing ped anim:", {
        entity = entity,
        dict = dict,
        name = name,
        blendIn = blendIn,
        blendOut = blendOut,
        duration = duration,
        flags = flags,
        rate = rate,
        ikFlags = ikFlags,
        filter = filter
    })
    -- Release only what THIS call asked the streamer for.
    --
    -- `RemoveAnimDict` was unconditional, so playing two anims from one dict released it TWICE while
    -- only requesting it once — the second call hands back a dict somebody else is still holding. The
    -- symptom is the second row of a shared dict: it looks like the animation is stopped rather than
    -- played, because the clip it needs has been marked reclaimable underneath a live task, and a
    -- looping full-body row is exactly the case where that shows.
    --
    -- A dict that was ALREADY loaded when we got here belongs to whoever loaded it (da_anims preloads
    -- every dict a state will use, and holds them for the life of the run) — releasing theirs is what
    -- caused the bug, so this call now leaves it alone.
    local wasLoaded = HasAnimDictLoaded(dict)
    LoadAnimDict(dict)
    -- ClearPedSecondaryTask(entity)
    TaskPlayAnim(entity, dict, name, blendIn, blendOut, duration, flags, rate, p8, ikFlags, p10, filter, p12)
    if not wasLoaded then RemoveAnimDict(dict) end
end

anim.object = function(entity, dict, name, p3, loop, stayInAnim, p6, delta, bitset)
    p3 = 0.0
    -- `loop`/`stayInAnim` are BOOL parameters and callers pass `loop = true` (every prop row in
    -- da_anims/lib does), so these keep their pass-through defaults — only `delta` is a float.
    loop = loop or 0
    stayInAnim = stayInAnim or 0
    p6 = ""
    delta = flt(delta, 0.0)
    bitset = bitset or 0

    log.spam("Playing object anim:", {
        entity = entity,
        dict = dict,
        name = name,
        p3 = p3,
        loop = loop,
        stayInAnim = stayInAnim,
        p6 = p6,
        delta = delta,
        bitset = bitset
    })
    LoadAnimDict(dict)
    PlayEntityAnim(entity, name, dict, p3, loop, stayInAnim, p6, delta, bitset)
    RemoveAnimDict(dict)
end

anim.adv = function(entity, dict, name, x, y, z, yaw, speed, speedMult, duration, flags, time, p14, p15, p16)
    x = flt(x, false)
    y = flt(y, false)
    z = flt(z, false)
    local pitch = 0.0
    local roll = 0.0
    yaw = flt(yaw, 0.0)
    speed = flt(speed, 1.0)
    speedMult = flt(speedMult, 1.0)
    duration = int(duration, -1)
    flags = int(flags, 0)
    time = flt(time, 0.0)
    p14 = p14 or 0
    p15 = p15 or 0
    p16 = p16 or 0

    log.spam("Playing advanced anim:", {
        dict = dict,
        name = name,
        x = x,
        y = y,
        z = z,
        yaw = yaw,
        speed = speed,
        speedMult = speedMult,
        duration = duration,
        flags = flags,
        time = time
    })
    LoadAnimDict(dict)
    TaskPlayAnimAdvanced(entity, dict, name, x, y, z, pitch, roll, yaw, speed, speedMult, duration, flags, time, p14, p15, p16)
    RemoveAnimDict(dict)
end

anim.get = function(entity, dict, name)
    if dict and name then
        if HasEntityAnimFinished(entity, dict, name) then
            return 0
        end
        return GetEntityAnimCurrentTime(entity, dict, name)
    else
        local playingAnim = IsEntityPlayingAnyAnim(entity, 1)
        return playingAnim
    end
end

anim.set = function(entity, dict, name, time, speedMulti)
    if time then
        -- A phase (0.0-1.0) and a speed multiplier are both floats: `anim.set(e, d, n, 1)` means
        -- "the end of the clip", not whatever an integer 1 lands on.
        time = flt(time, 0.0)
        if time < 0 then
            StopEntityAnim(entity, dict, name, 0.0)
        else
            SetEntityAnimCurrentTime(entity, dict, name, time)
        end
    end
    if speedMulti then
        SetEntityAnimSpeed(entity, dict, name, flt(speedMulti, 1.0))
    end
end

anim.stop = function(ped)
    ClearPedTasks(ped)
end

_ENV.da_anim = anim
