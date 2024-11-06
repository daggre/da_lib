local object = {}

object.load = function(hash)
    if not IsModelInCdimage(hash) then return false end

    RequestModel(hash)
    local cutoff = GetGameTimer() + 3000
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
        if GetGameTimer() > cutoff then
            return false
        end
    end

    return true
end


object.create = function(hash, coords, opts)
    if not hash or not coords then return; end
    if not object.load(hash) then return; end

    local isNetwork = opts and opts.network or false
    local netMissionEntity = opts and opts.netMissionEntity or false
    local doorFlag = opts and opts.doorFlag ~= false
    -- Create the object
    local obj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, isNetwork, netMissionEntity, doorFlag)
    if opts then
        -- Set the spawned objects parameters based on the options config
        object.set(obj, opts)
    end
    -- Unload the model from memory
    SetModelAsNoLongerNeeded(hash)
    return obj
end

object.delete = function(obj)
    if DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
end

object.createVehicle = function(hash, pos, opts)
    if not hash or not pos then return; end
    -- Load the model into memory
    if not object.load(hash) then return; end

    local preventDraftAnimals = not opts or opts and opts.preventDraftAnimals ~= false
    local isNetwork = opts and opts.network or false
    local scriptHostVeh = opts and opts.scriptHostVeh or false
    -- Create the vehicle
    local obj = CreateVehicle(hash, pos.x, pos.y, pos.z, pos.w, isNetwork, scriptHostVeh, preventDraftAnimals)
    if opts then
        -- Set the spawned vehicles parameters based on the options config
        object.set(obj, opts)
    end
    -- Unload the model from memory
    SetModelAsNoLongerNeeded(hash)
    return obj
end

object.expression = function(obj, expr, val, type)
    type = type or 0
    Citizen.InvokeNative(0x669655FFB29EF1A9, obj, type, expr, tonumber(val) + 0.0)
end

object.attach = function(obj, tgt, boneIdx, pos, rot, opts)
    -- Check if the objects exist
    if not DoesEntityExist(obj) or not DoesEntityExist(tgt) then return; end

    -- Attach the object to the target's bone
    AttachEntityToEntity(obj, tgt, boneIdx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true, false, false)
    if opts then
        -- Set the attached objects parameters based on the options config
        object.set(obj, opts)
    end
end

object.detach = function(obj)
    -- Check if the object exists
    if not DoesEntityExist(obj) then return; end
    -- Detach the object
    DetachEntity(obj, true, true)
end

object.set = function(obj, opt)
    if not opt then return; end

    if opt.rotation ~= nil then
        -- If a rotation is provided set the rotation
        SetEntityRotation(obj, opt.rotation.x, opt.rotation.y, opt.rotation.z, 0, true)
    end

    if opt.heading then
        -- If the heading is provided set the heading
        SetEntityHeading(obj, opt.heading)
    elseif opt.position and opt.position.w then
        -- If the heading is provided as a vector4 set the heading
        SetEntityHeading(obj, opt.position.w)
    end

    if opt.ground then
        -- If the object should be placed on the ground using the native
        PlaceObjectOnGroundProperly(obj, true)
    end

    if opt.collision ~= nil then
        if opt.collisionKeepPhysics == nil then opt.collisionKeepPhysics = true; end
        --  If collision is provided set the collision
        SetEntityCollision(obj, opt.collision, opt.collisionKeepPhysics)
    end

    if opt.visible ~= nil then
        -- If visibility is provided set the visibility
        SetEntityVisible(obj, opt.visible)
    end

    -- The object should be frozen unless explicitly set to false
    opt.frozen = opt.frozen ~= false -- default true
    if opt.settleFreeze ~= nil then
        -- If a settle freeze time is provided freeze the object after the time
        Citizen.SetTimeout(opt.settleFreeze, function()
            FreezeEntityPosition(obj, opt.frozen)
        end)
    else
        -- If no settle freeze time is provided set the object frozen state immediately
        FreezeEntityPosition(obj, opt.frozen)
    end

    if opt.texture then
        -- If a texture is provided set the texture
        SetEntityTextureVariation(obj, opt.texture)
    end

    if opt.lod ~= nil and opt.lod > -1 then
        -- If a LOD is provided set the level of detail distance
        Citizen.InvokeNative(0x5FB407F0A7C877BF, obj, opt.lod)
    end

    if opt.fadeIn then
        -- If fade in is provided fade the object in
        Citizen.InvokeNative(0xA91E6CF94404E8C9, obj)
    end

    if opt.vehicle then
        -- If the object is a vehicle set the vehicle parameters
        if opt.vehicle.tint then
            -- Set the vehicle colors
            Citizen.InvokeNative(0x8268B098F6FCA4E2, obj, opt.vehicle.tint) -- SetVehicleTint
        end
        if opt.vehicle.livery then
            -- Set the vehicle livery
            Citizen.InvokeNative(0xF89D82A0582E46ED, obj, opt.vehicle.livery) -- SetVehicleLivery
        end
        -- Clear the vehicle light props
        Citizen.InvokeNative(0xE31C0CB1C3186D40, obj) -- RemoveVehicleLightPropSets
        if opt.vehicle.lanterns then
            -- Set the vehicle light props
            Citizen.InvokeNative(0xC0F0417A90402742, obj, opt.vehicle.lanterns) -- AddLightPropSetToVehicle
        end
        if opt.vehicle.propset then
            -- Set the vehicle prop set for the contents in the wagon
            Citizen.InvokeNative(0xD80FAF919A2E56EA, obj, opt.vehicle.propset) -- AddPropSetForVehicle
        end
        if opt.vehicle.extra then
            for i = 1, 16 do
                if Citizen.InvokeNative(0xFA9A55D9C4351625, obj, i) then -- IsVehicleExtraTurnedOn
                    Citizen.InvokeNative(0xBB6F89150BC9D16B, obj, i, 1) -- SetVehicleExtra
                end
            end
            Citizen.InvokeNative(0xBB6F89150BC9D16B, obj, opt.vehicle.extra, 0) -- SetVehicleExtra
        end
    end
end

_ENV.da_obj = object
