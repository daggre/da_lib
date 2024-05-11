local LoadAnimDict = function(animDict)
    local timeout = GetGameTimer() + 200
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(5)
        RequestAnimDict(animDict)
        if GetGameTimer() > timeout then
            return false
        end
    end
    return true
end

Lib.Anim.Ped = function(entity, animDict, animName, blendIn, blendOut, duration, flags, playbackRate, ikFlags, taskFilter)
    blendIn = tonumber(blendIn) or 3.0
    blendOut = tonumber(blendOut) or 3.0
    duration = tonumber(duration) or -1
    flags = tonumber(flags) or 0
    playbackRate = tonumber(playbackRate) or 0
    ikFlags = tonumber(ikFlags) or 0
    local p10 = 0
    taskFilter = false
    local p12 = 0

    LoadAnimDict(animDict)
    ClearPedSecondaryTask(entity)
    Lib.Log.DebugVerbose(("Anim:Ped %s %s in:%.1f out:%.1f dur:%d flags:%d rate:%d ik:%d"):format(
        animDict, animName, blendIn, blendOut, duration, flags, playbackRate, ikFlags
    ))
    TaskPlayAnim(entity, animDict, animName, blendIn, blendOut, duration, flags, playbackRate, ikFlags, p10, taskFilter, p12)
    RemoveAnimDict(animDict)
end

Lib.Anim.Adv = function(entity, animDict, animName, posX, posY, posZ, rotZ, speed, speedMultiplier, duration, flags, animTime, p14, p15, p16)
    posX = tonumber(posX) or false
    posY = tonumber(posY) or false
    posZ = tonumber(posZ) or false
    local rotX = 0.0
    local rotY = 0.0
    rotZ = tonumber(rotZ) or 0.0
    speed = tonumber(speed) or 1.0
    speedMultiplier = tonumber(speedMultiplier) or 1.0
    duration = tonumber(duration) or -1
    flags = tonumber(flags) or 0
    -- animTime = tonumber(animTime) or 0.0
    p14 = p14 or 0
    p15 = p15 or 0
    p16 = p16 or 0

    LoadAnimDict(animDict)
    Lib.Log.DebugVerbose(("Anim:Adv %s %s pos:%.1f %.1f %.1f rot:%.1f speed:%.1f mult:%.1f dur:%d flags:%d time:%.1f"):format(
        animDict, animName, posX, posY, posZ, rotZ, speed, speedMultiplier, duration, flags, animTime
    ))
    TaskPlayAnimAdvanced(entity, animDict, animName, posX, posY, posZ, rotX, rotY, rotZ, speed, speedMultiplier, duration, flags, animTime, p14, p15, p16)
    RemoveAnimDict(animDict)
end

Lib.Anim.Object = function(entity, animDict, animName, p3, loop, stayInAnim, p6, delta, bitset)
    p3 = 0.0
    loop = loop or 0
    stayInAnim = stayInAnim or 0
    p6 = ""
    delta = delta or 0.0
    bitset = bitset or 0

    Lib.Log.DebugVerbose(("Anim:Object %s %s loop:%s stay:%s delta:%.1f bitset:%d"):format(
        animDict, animName, loop, stayInAnim, delta, bitset
    ))
    LoadAnimDict(animDict)
    PlayEntityAnim(entity, animName, animDict, p3, loop, stayInAnim, p6, delta, bitset)
    RemoveAnimDict(animDict)
end
