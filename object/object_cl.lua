--- Copyright © 2024 Joshua Nelson



Lib.Obj.Load = function(modelHash)
    if not IsModelInCdimage(modelHash) then
        return false
    end

    RequestModel(modelHash)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
        if GetGameTimer() > timeout then
            return false
        end
    end

    return true
end

Lib.Obj.Create = function(modelHash, coords, option)
    if not modelHash or not coords then return; end
    if not Lib.Obj.Load(modelHash) then return; end

    local isNetwork = option and option.network or false
    local netMissionEntity = option and option.netMissionEntity or false
    local doorFlag = option and option.doorFlag ~= false
    local obj = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z, isNetwork, netMissionEntity, doorFlag)
    if option then
        Lib.Obj.SetParameters(obj, option)
    end
    SetModelAsNoLongerNeeded(modelHash)
    return obj
end

Lib.Obj.Delete = function(entity)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

Lib.Obj.SetParameters = function(entity, option)
    if not option then return; end

    if option.rotation ~= nil then
        SetEntityRotation(entity, option.rotation.x, option.rotation.y, option.rotation.z, 0, true)
    end

    if option.heading then
        SetEntityHeading(entity, option.heading)
    elseif option.position and option.position.w then
        SetEntityHeading(entity, option.position.w)
    end

    if option.ground then
        PlaceObjectOnGroundProperly(entity, true)
    end

    if option.collision ~= nil then
        SetEntityCollision(entity, option.collision, true)
    end

    if option.visible ~= nil then
        SetEntityVisible(entity, option.visible)
    end

    option.frozen = option.frozen ~= false -- default true
    FreezeEntityPosition(entity, option.frozen)

    if option.texture then
        SetEntityTextureVariation(entity, option.texture)
    end

    if option.lod ~= nil and option.lod > -1 then
        Citizen.InvokeNative(0x5FB407F0A7C877BF, entity, option.lod)
    end

    if option.fadeIn then
        Citizen.InvokeNative(0xA91E6CF94404E8C9, entity)
    end
end

Lib.Obj.SetExpression = function(entity, expression, value, type)
    type = type or 0
    Citizen.InvokeNative(0x669655FFB29EF1A9, entity, type, expression, tonumber(value) + 0.0)
end

Lib.Obj.Attach = function(entity, target, boneIndex, position, rotation, option)
    if not DoesEntityExist(entity) or not DoesEntityExist(target) then return; end

    AttachEntityToEntity(entity, target, boneIndex, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, true, true, false, true, 1, true, false, false)
    if option then
        Lib.Obj.SetParameters(entity, option)
    end
end
