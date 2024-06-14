--- Load an animation dictionary
---@param animDict string
---@return boolean boolean Did the animDict load
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

--- Play an animation on a ped
---@param entity number entity id
---@param animDict string animation dictionary
---@param animName string animation name
---@param blendIn number animation blend in speed
---@param blendOut number animation blend out speed
---@param duration number length in ms the animation should play
---@param flags number flags determining how the animation is applied to the entity
---@param playbackRate number speed of the animation (doesn't work on peds)
---@param ikFlags number flags determining the inverse kinematics
---@param taskFilter any overrides to false
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

--- Play an animation on an entity using advanced parameters
---@param entity number entity id
---@param animDict string animation dictionary
---@param animName string animation name
---@param posX number|boolean x coordinate to playback the animation from
---@param posY number|boolean y coordinate to playback the animation from
---@param posZ number|boolean z coordinate to playback the animation from
---@param rotZ number rotation on the z axis to apply to the animation
---@param speed number the playback speed of the animation
---@param speedMultiplier any the speed multiplier of the animation
---@param duration number length in ms the animation should play
---@param flags number flags determining how the animation is applied to the entity
---@param animTime any the time in the animation to start playing from
---@param p14 any unknown
---@param p15 any unknown
---@param p16 any unknown
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

--- Play an object animation
---@param entity number entity id of the object
---@param animDict string animation dictionary
---@param animName string animation name
---@param p3 any unknown
---@param loop number loop the animation
---@param stayInAnim number stay in the animation
---@param p6 string unknown
---@param delta number unknown
---@param bitset number unknown
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

--- Set the current time and speed of an animation playing on an object
---@param entity number entity id of the object
---@param animDict string animation dictionary
---@param anim string animation name
---@param time number|nil the time in the animation to play from
---@param speedMultiplier number|nil the speed multiplier of the animation
Lib.Anim.SetObject = function(entity, animDict, anim, time, speedMultiplier)
    if time then
        if time < 0 then
            StopEntityAnim(entity, animDict, anim, 0.0)
        else
            SetEntityAnimCurrentTime(entity, animDict, anim, time)
        end
    end
    if speedMultiplier then
        SetEntityAnimSpeed(entity, animDict, anim, speedMultiplier)
    end
end

--- Get the animation state of an entity
---@param entity number entity id
---@param animDict string animation dictionary currently playing
---@param anim string animation name currently playing
---@return integer time current time in the animation or 0
Lib.Anim.GetState = function(entity, animDict, anim)
    if animDict and anim then
        if HasEntityAnimFinished(entity, animDict, anim) then
            Lib.Log.Debug(("Anim:GetState %s %s finished"):format(animDict, anim))
            return 0
        end
        return GetEntityAnimCurrentTime(entity, animDict, anim)
    else
        local playingAnim = IsEntityPlayingAnyAnim(entity, 1)
        Lib.Log.Debug(("Anim:GetState EntityPlayingAnim %s"):format(playingAnim))
        return playingAnim
    end
end

