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

anim.ped = function(entity, dict, name, blendIn, blendOut, duration, flags, rate, ikFlags, taskFilter)
    blendIn = tonumber(blendIn) or 3.0
    blendOut = tonumber(blendOut) or 0.5
    duration = tonumber(duration) or -1
    flags = tonumber(flags) or 0
    rate = tonumber(rate) or 0
    local p8 = false
    ikFlags = tonumber(ikFlags) or 0
    local p10 = false
    taskFilter = taskFilter ~= nil and taskFilter or false
    local p12 = false

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
        taskFilter = taskFilter
    })
    LoadAnimDict(dict)
    -- ClearPedSecondaryTask(entity)
    TaskPlayAnim(entity, dict, name, blendIn, blendOut, duration, flags, rate, p8, ikFlags, p10, taskFilter, p12)
    RemoveAnimDict(dict)
end

anim.object = function(entity, dict, name, p3, loop, stayInAnim, p6, delta, bitset)
    p3 = 0.0
    loop = loop or 0
    stayInAnim = stayInAnim or 0
    p6 = ""
    delta = delta or 0.0
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
    x = tonumber(x) or false
    y = tonumber(y) or false
    z = tonumber(z) or false
    local pitch = 0.0
    local roll = 0.0
    yaw = tonumber(yaw) or 0.0
    speed = tonumber(speed) or 1.0
    speedMult = tonumber(speedMult) or 1.0
    duration = tonumber(duration) or -1
    flags = tonumber(flags) or 0
    time = tonumber(time) or 0.0
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
        if time < 0 then
            StopEntityAnim(entity, dict, name, 0.0)
        else
            SetEntityAnimCurrentTime(entity, dict, name, time)
        end
    end
    if speedMulti then
        SetEntityAnimSpeed(entity, dict, name, speedMulti)
    end
end

anim.stop = function(ped)
    ClearPedTasks(ped)
end

_ENV.da_anim = anim
