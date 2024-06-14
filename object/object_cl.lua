--- Copyright © 2024 Joshua Nelson

---Load a model into memory in preparation for spawning the object
---@param modelHash any
---@return boolean
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

---Spawn the object into the world
---@param modelHash integer The model hash of the object
---@param coords table The coordinates of the object
---@param option table|nil The parameters for the spawned object
---@return integer|nil entityHandle The entity handle of the object
Lib.Obj.Create = function(modelHash, coords, option)
    if not modelHash or not coords then return; end
    -- Load the model into memory
    if not Lib.Obj.Load(modelHash) then return; end

    local isNetwork = option and option.network or false
    local netMissionEntity = option and option.netMissionEntity or false
    local doorFlag = option and option.doorFlag ~= false
    -- Create the object
    local obj = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z, isNetwork, netMissionEntity, doorFlag)
    if option then
        -- Set the spawned objects parameters based on the options config
        Lib.Obj.SetParameters(obj, option)
    end
    -- Unload the model from memory
    SetModelAsNoLongerNeeded(modelHash)
    return obj
end

---Create a vehicle in the world
---@param modelHash integer The model hash of the vehicle
---@param coords table The coordinates of the vehicle
---@param option table|nil The parameters for the spawned vehicle
---@return integer|nil entityHandle The entity handle of the vehicle
Lib.Obj.CreateVehicle = function(modelHash, coords, option)
    if not modelHash or not coords then return; end
    -- Load the model into memory
    if not Lib.Obj.Load(modelHash) then return; end

    local preventDraftAnimals = not option or option and option.preventDraftAnimals ~= false
    local isNetwork = option and option.network or false
    local scriptHostVeh = option and option.scriptHostVeh or false
    -- Create the vehicle
    local obj = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, isNetwork, scriptHostVeh, preventDraftAnimals)
    if option then
        -- Set the spawned vehicles parameters based on the options config
        Lib.Obj.SetParameters(obj, option)
    end
    -- Unload the model from memory
    SetModelAsNoLongerNeeded(modelHash)
    return obj
end

---Delete an object from the world
---@param entity integer|nil The entity handle of the object
Lib.Obj.Delete = function(entity)
    -- Check if the object exists
    if DoesEntityExist(entity) then
        -- Delete the object
        DeleteEntity(entity)
    end
end

---Set the parameters of the spawned object
---@param entity integer The entity handle of the object
---@param option table The parameters for the spawned object
Lib.Obj.SetParameters = function(entity, option)
    if not option then return; end

    if option.rotation ~= nil then
        -- If a rotation is provided set the rotation
        SetEntityRotation(entity, option.rotation.x, option.rotation.y, option.rotation.z, 0, true)
    end

    if option.heading then
        -- If the heading is provided set the heading
        SetEntityHeading(entity, option.heading)
    elseif option.position and option.position.w then
        -- If the heading is provided as a vector4 set the heading
        SetEntityHeading(entity, option.position.w)
    end

    if option.ground then
        -- If the object should be placed on the ground using the native
        PlaceObjectOnGroundProperly(entity, true)
    end

    if option.collision ~= nil then
        --  If collision is provided set the collision
        SetEntityCollision(entity, option.collision, true)
    end

    if option.visible ~= nil then
        -- If visibility is provided set the visibility
        SetEntityVisible(entity, option.visible)
    end

    -- The object should be frozen unless explicitly set to false
    option.frozen = option.frozen ~= false -- default true
    if option.settleFreeze ~= nil then
        -- If a settle freeze time is provided freeze the object after the time
        Citizen.SetTimeout(option.settleFreeze, function()
            FreezeEntityPosition(entity, option.frozen)
        end)
    else
        -- If no settle freeze time is provided set the object frozen state immediately
        FreezeEntityPosition(entity, option.frozen)
    end

    if option.texture then
        -- If a texture is provided set the texture
        SetEntityTextureVariation(entity, option.texture)
    end

    if option.lod ~= nil and option.lod > -1 then
        -- If a LOD is provided set the level of detail distance
        Citizen.InvokeNative(0x5FB407F0A7C877BF, entity, option.lod)
    end

    if option.fadeIn then
        -- If fade in is provided fade the object in
        Citizen.InvokeNative(0xA91E6CF94404E8C9, entity)
    end

    if option.vehicle then
        -- If the object is a vehicle set the vehicle parameters
        if option.vehicle.tint then
            -- Set the vehicle colors
            Citizen.InvokeNative(0x8268B098F6FCA4E2, entity, option.vehicle.tint) -- SetVehicleTint
        end
        if option.vehicle.livery then
            -- Set the vehicle livery
            Citizen.InvokeNative(0xF89D82A0582E46ED, entity, option.vehicle.livery) -- SetVehicleLivery
        end
        -- Clear the vehicle light props
        Citizen.InvokeNative(0xE31C0CB1C3186D40, entity) -- RemoveVehicleLightPropSets
        if option.vehicle.lanterns then
            -- Set the vehicle light props
            Citizen.InvokeNative(0xC0F0417A90402742, entity, option.vehicle.lanterns) -- AddLightPropSetToVehicle
        end
        if option.vehicle.propset then
            -- Set the vehicle prop set for the contents in the wagon
            Citizen.InvokeNative(0xD80FAF919A2E56EA, entity, option.vehicle.propset) -- AddPropSetForVehicle
        end
        if option.vehicle.extra then
            for i = 1, 16 do
                if Citizen.InvokeNative(0xFA9A55D9C4351625, entity, i) then -- IsVehicleExtraTurnedOn
                    Citizen.InvokeNative(0xBB6F89150BC9D16B, entity, i, 1) -- SetVehicleExtra
                end
            end
            Citizen.InvokeNative(0xBB6F89150BC9D16B, entity, option.vehicle.extra, 0) -- SetVehicleExtra
        end
    end
end

---Set the visible prop state of the spawned object
---@param entity integer The entity handle of the object
---@param expression string The expression name to set
---@param value number The value to set the expression to
---@param type integer The type of expression to set
Lib.Obj.SetExpression = function(entity, expression, value, type)
    type = type or 0
    Citizen.InvokeNative(0x669655FFB29EF1A9, entity, type, expression, tonumber(value) + 0.0)
end

---Attach an entity to another entity
---@param entity integer The entity handle of the attaching object
---@param target integer The entity handle of the object being attached to
---@param boneIndex integer The bone index of the entity bone to attach the object to
---@param position table The position of the object relative to the bone
---@param rotation table The rotation of the object relative to the bone
---@param option table|nil Additional parameters for the attached object
Lib.Obj.Attach = function(entity, target, boneIndex, position, rotation, option)
    -- Check if the objects exist
    if not DoesEntityExist(entity) or not DoesEntityExist(target) then return; end

    -- Attach the object to the target's bone
    AttachEntityToEntity(entity, target, boneIndex, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, true, true, false, true, 1, true, false, false)
    if option then
        -- Set the attached objects parameters based on the options config
        Lib.Obj.SetParameters(entity, option)
    end
end

---Detach an entity from another entity
---@param entity integer The entity handle of the object to detach
Lib.Obj.Detach = function(entity)
    -- Check if the object exists
    if not DoesEntityExist(entity) then return; end
    -- Detach the object
    DetachEntity(entity, true, true)
end
