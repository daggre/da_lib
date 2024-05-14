local RequestNamedPtfxAsset = function(ptfxDictHash) Citizen.InvokeNative(0xF2B2353BBC0D4E8F, ptfxDictHash) end

local HasNamedPtfxAssetLoaded = function(ptfxDictHash) Citizen.InvokeNative(0x65BB72F29138F5D6, ptfxDictHash) end

local LoadPtfxDict = function(ptfxDictHash)
    if HasNamedPtfxAssetLoaded(ptfxDictHash) then return true; end

    RequestNamedPtfxAsset(ptfxDictHash)
    local timeout = GetGameTimer() + 1000
    while not HasNamedPtfxAssetLoaded(ptfxDictHash) do
        if GetGameTimer() > timeout then
            return false
        end
        Citizen.Wait(100)
    end
    return true
end

local UsePtfxAsset = function(ptfxDictHash) Citizen.InvokeNative(0xA10DB07FC234DD12, ptfxDictHash) end

local StartParticleFxLoopedOnEntity = function(ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x1AE42C1660FD6517, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxOnEntity = function(ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x8F90ABD54E5C5A63, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxLoopedOnBone = function(ptfxName, entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xE689C1B1432BB8AF, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, boneIndex, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxOnBone = function(ptfxName, entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x3FAA72BD940C3AC0, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, boneIndex, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxLoopedAtCoord = function(ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x6E06C0D8B3921E5C, ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxAtCoord = function(ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x2E80BF72EF7C87AC, ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartPtfx = function(ptfxName, options)
    local coords = options.coords.xyz
    local boneIndex = options.entity and options.bone and GetEntityBoneIndexByName(options.entity, options.bone) or false
    local xRot = options.coords.xRot or 0.0
    local yRot = options.coords.yRot or 0.0
    local zRot = options.coords.zRot or 0.0
    local scale = options.scale or 1.0
    local xAxis = options.xAxis or 0
    local yAxis = options.yAxis or 0
    local zAxis = options.zAxis or 0

    if options.entity then
        if options.bone then
            if options.loop then
                return StartParticleFxLoopedOnBone(ptfxName, options.entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            else
                return StartParticleFxOnBone(ptfxName, options.entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            end
        else
            if options.loop then
                return StartParticleFxLoopedOnEntity(ptfxName, options.entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            else
                return StartParticleFxOnEntity(ptfxName, options.entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            end
        end
    elseif options.coords then
        if options.loop then
            return StartParticleFxLoopedAtCoord(ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
        else
            return StartParticleFxAtCoord(ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
        end
    end
end

local DoesParticleFxExist = function(ptfxHandle)
    return Citizen.InvokeNative(0x9DD5AFF561E88F2A, ptfxHandle)
end

local RemoveParticleFx = function(ptfxHandle, p2)
    return Citizen.InvokeNative(0x459598F579C98929, ptfxHandle, p2)
end

local RemoveParticleFxFromEntity = function(entity)
    return Citizen.InvokeNative(0x92884B4A49D81325, entity)
end

local RemoveParticleFxInRange = function(x, y, z, radius)
    return Citizen.InvokeNative(0x87B5905ECA623B68, x, y, z, radius)
end

Lib.Fx.New = function(ptfxDict, ptfxName, options)
    local ptfxDictHash = GetHashKey(ptfxDict)
    if not LoadPtfxDict(ptfxDictHash) then return; end
    UsePtfxAsset(ptfxDict)
    StartPtfx(ptfxName, options)
end

Lib.Fx.Remove = function(options)
    if options.handle then
        if DoesParticleFxExist(ptfxHandle) then
            RemoveParticleFx(ptfxHandle)
        end
    elseif options.entity then
        RemoveParticleFxFromEntity(entity)
    elseif options.coords then
        RemoveParticleFxInRange(options.coords.x, options.coords.y, options.coords.z, options.radius or 1.0)
    end
end

