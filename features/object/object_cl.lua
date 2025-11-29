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

object.createObj = function(hash, coords, opts)
    log.spam("Creating object", hash)
    if not hash or not coords then log.spam("Invalid hash/coords", hash, coords); return; end
    if not object.load(hash) then log.debug("Failed to load hash", hash) return; end

    local isNetwork = opts and opts.network or false
    local netMissionEntity = opts and opts.netMissionEntity or false
    local doorFlag = opts and opts.doorFlag ~= false
    -- Create the object
    log.spam("Creating object", hash, coords.x, coords.y, coords.z, opts)
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

object.createPed = function(hash, pos, opts)
    if not hash or not pos then return; end
    -- Load the model into memory
    if not object.load(hash) then return; end

    local isNetwork = opts and opts.network or false
    local obj = CreatePed(hash, pos.x, pos.y, pos.z, pos.w, isNetwork, true, false)
    if opts then
        object.set(obj, opts)
    end
    if not opts or not opts.outfit then
        SetPedOutfitPreset(obj, 0, false)
    end
    -- Unload the model from memory
    SetModelAsNoLongerNeeded(hash)
    return obj
end

object.loadPropset = function(hash)
    RequestPropset(hash)

    local cutoff = GetGameTimer() + 500
    while not HasPropsetLoaded(hash) do
        Wait(0)
        if GetGameTimer() > cutoff then
            return false
        end
    end

    return true
end

object.propsetFullyLoaded = function(propset)
    local cutoff = GetGameTimer() + 500
    while not IsPropSetFullyLoaded(propset) do
        Wait(0)
        if GetGameTimer() > cutoff then
            return false
        end
    end

    return true
end

object.convertPropset = function(propset)
    if not object.propsetFullyLoaded(propset) then return; end

    local itemset = CreateItemset(true)
    local size = GetEntitiesFromPropset(propset, itemset, 0, false, false)

    if size > 0 then
        for i = 0, size - 1 do
            local obj = GetIndexedItemInItemset(i, itemset)
            if obj and DoesEntityExist(obj) then
                CloneEntity(obj)
            end
        end
    end

    if IsItemsetValid(itemset) then
        DestroyItemset(itemset)
    end

    DeletePropset(propset, false, false)

    return nil
end

object.createPropset = function(hash, pos, opts)
    if true then
        log.warn("Create Propset is currently disabled.")
        return nil
    end

    if not object.loadPropset(hash) then return; end
    local propset = CreatePropset(hash, pos.x, pos.y, pos.z, 0, pos.w, 0.0, false, false)
    ReleasePropset(hash)

    if not propset or propset < 1 then
        return nil
    end

    -- object.convertPropset()
    return propset
end

object.createPickup = function(hash, pos, opts)
    if true then
        log.warn("Create Pickup is currently disabled.")
        return nil
    end

    if not hash or not pos then return; end


    if not IsPickupTypeValid(hash) then
        log.error("Invalid pickup type", hash)
        return nil
    end

    local obj = CreatePickup(hash, pos.x, pos.y, pos.z, false, 0, 0, 0, 0, 0.0, 0)
    if opts then
        object.set(obj, opts)
    end

    return obj
end

object.create = function(hash, pos, opts, objType)
    local handle = nil
    objType = objType or object.getType(hash)
    if objType == nil or objType == "object" then
        handle = object.createObj(hash, pos, opts)
    elseif objType == "ped" then
        handle = object.createPed(hash, pos, opts)
    elseif objType == "vehicle" then
        handle = object.createVehicle(hash, pos, opts)
    elseif objType == "propset" then
        handle = object.createPropset(hash, pos, opts)
    elseif objType == "pickup" then
        handle = object.createPickup(hash, pos, opts)
    end
    if not handle then
        log.error("Failed to create object", hash, pos, objType)
    end
    return handle
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
    if not obj then return; end
    if not opt then return; end
    obj = tonumber(obj)

    if opt.quaternion then
        -- If a quaternion is provided use the quaternion
        SetEntityQuaternion(obj, opt.quaternion.x, opt.quaternion.y, opt.quaternion.z, -opt.quaternion.w)
    else
        if opt.rotation ~= nil then
            -- If a rotation is provided set the rotation
            SetEntityRotation(obj, opt.rotation.x, opt.rotation.y, opt.rotation.z, opt.rotation_order or 0, true)
        end

        if opt.heading then
            -- If the heading is provided set the heading
            SetEntityHeading(obj, opt.heading)
        elseif opt.position and opt.position.w then
            -- If the heading is provided as a vector4 set the heading
            SetEntityHeading(obj, opt.position.w)
        end
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
    if opt.frozen ~= nil then
        if opt.settleFreeze ~= nil then
            -- If a settle freeze time is provided freeze the object after the time
            Citizen.SetTimeout(opt.settleFreeze, function()
                FreezeEntityPosition(obj, opt.frozen)
            end)
        else
            -- If no settle freeze time is provided set the object frozen state immediately
            FreezeEntityPosition(obj, opt.frozen)
        end
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

    if opt.alpha then
        SetEntityAlpha(obj, opt.alpha, false)
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

    if opt.outfit then
        SetPedOutfitPreset(obj, opt.outfit, false)
    end
end

object.getType = function(hash)
    for _, objType in ipairs({"ped", "vehicle", "object", "pickup", "propset"}) do
        if dat.lookup[objType] and dat.lookup[objType][hash] then
            return objType
        end
    end
    return nil
end

_ENV.da_obj = object
