--- Copyright © 2024 Joshua Nelson

local ZoneCacheId = "IntZoneCache"
local PropCacheId = "IntPropCache"
local InteractPropZoneId = "IntPropZone"
local InteractZoneId = "IntZone"
local DefaultZoneRange = 60
local DefaultInteractionRange = 1.9

---Create an interactive object in the world
---@param data table The creation parameter data for the objects creation
local CreateProp = function(data)
    -- Check if the prop exists
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id) or Lib.Cache.Temp.Hit(PropCacheId, data.id) then return; end
    -- Initialize the spawn parameters if they dont exist
    data.spawnParams = data.spawnParams or {}

    Lib.Log.Debug("Creating intprop:", data)
    -- Create the object
    local entity = Lib.Obj.Create(data.objectHash, data.coords, data.spawnParams)
    -- If the object is a bucket and has a metadata resourceAmount
    if data.objectHash == `p_bucket03x` and data.metadata and data.metadata.resourceAmount then

        -- Set the prop expression on the bucket creating the visible water level
        Lib.Obj.SetExpression(entity, "bucket_Fill", data.metadata.resourceAmount)
        Lib.Log.DebugVerbose("Creating bucket, setting resource amount to "..tostring(data.metadata.resourceAmount))
    end
    -- Cache the object
    Lib.Cache.Temp.Add(PropCacheId, data.id, entity, true)
end

-- Delete a prop from the world
local DeleteProp = function(id)
    -- Get the entity handle from the cache
    local entity = Lib.Cache.Temp.Get(PropCacheId, id)
    -- Delete the entity
    Lib.Obj.Delete(entity)
    -- Remove the entity from the cache
    Lib.Cache.Temp.Remove(PropCacheId, id)
end

---Add an interactive zone (Polyzone circle) to the world
---@param data table The prop data to create the interactive zone
local AddInteractivePropZone = function(data)
    --  If the prop does not have an interact range then return
    if data.metadata.interactRange == nil then return; end
    Lib.Log.Debug("Adding IntProp InteractivePropZone", data)
    assert(data.metadata and data.metadata.interactType ~= nil, "Missing interactType")
    assert(data.metadata and data.metadata.interactTypeSpecific ~= nil, "Missing interactTypeSpecific")
    -- Create the polyzone circle zone
    local zone = Lib.PolyZone.Circle(
        InteractZoneId,
        data.coords,
        data.metadata and data.metadata.interactRange or DefaultInteractionRange,
        {
            data = data,
            -- Set the debug color to purple
            debugColor = { 200, 0, 255 },
            useZ = true,
        })
    -- Cache the zone id for use in zone interaction
    Lib.Cache.Temp.Add(ZoneCacheId, data.id.."_int", zone, true)
end

---Register the function that is triggered when entering any zone with the InteractZoneId
---@param data table The zones data which is passed to the function on enter
Lib.PolyZone.OnEnter(InteractZoneId, function(data)
    -- If the zone is not cached then return
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id.."_int") then return; end
    -- Trigger the interactionZone:enter event
    TriggerEvent("interactionZone:enter", data)
end)

---Register the function that is triggered when exiting any zone with the InteractZoneId
---@param data table The zones data which is passed to the function on exit
Lib.PolyZone.OnExit(InteractZoneId, function(data)
    -- If the zone is not cached then return
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id.."_int") then return; end
    -- Trigger the interactionZone:exit event
    TriggerEvent("interactionZone:exit", data)
end)

---Add a prop zone to the world used for loading/unloading the prop entity
---@param data any
local AddPropZone = function(data)
    local zoneRange = DefaultZoneRange
    local zone = Lib.PolyZone.Circle(InteractPropZoneId, data.coords, zoneRange, {
        data = data,
        debugColor = { 155, 0, 255 }
    })
    Lib.Cache.Temp.Add(ZoneCacheId, data.id, zone, true)
    -- Attempt to add the prop as an interactive prop
    AddInteractivePropZone(data)
end

-- When a player enters the prop zone create the prop
Lib.PolyZone.OnEnter(InteractPropZoneId, function(data)
    CreateProp(data)
end)

-- When a player exits the prop zone delete the prop
Lib.PolyZone.OnExit(InteractPropZoneId, function(data)
    DeleteProp(data.id)
end)

-- Remove a prop and prop zone from the world
local RemoveProp = function(data)
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id) then return; end
    Lib.Log.Debug("Removing IntProp Prop Zone", data)
    -- Delete the prop
    DeleteProp(data.id)
    -- Remove the prop zone
    Lib.Cache.Temp.Remove(ZoneCacheId, data.id)
    -- Remove the interaction zone
    Lib.Cache.Temp.Remove(ZoneCacheId, data.id.."_int")
    TriggerEvent("interactionZone:exit", data)
end

-- Add a prop and prop zone to the world
local AddProp = function(propData)
    assert(type(propData.objectHash) == "number", string.format("Invalid prop: %s", Lib.String.Format(propData.objectHash)))
    assert(type(propData.coords) == "vector3", string.format("Invalid coords: %s", Lib.String.Format(propData.coords)))
    -- Remove the prop if it already exists
    RemoveProp({id = propData.id})
    -- Add the prop zone
    AddPropZone(propData)
end

RegisterNetEvent("intprop:client:add")
AddEventHandler("intprop:client:add", function(data)
    AddProp(data)
end)

RegisterNetEvent("intprop:client:remove")
AddEventHandler("intprop:client:remove", function(data)
    RemoveProp(data)
end)

-- A local function that checks the propData structure that is passed to CreateIntProp
local function _checkPropData(objectHash, coords, metadata)
    assert(type(objectHash) == "number", string.format("Invalid prop: %s", objectHash))
    assert(type(coords) == "vector3", string.format("Invalid coords: %s", Lib.String.Format(coords)))
    assert(type(metadata) == "table", string.format("Invalid metadata: %s", Lib.String.Format(metadata)))
    assert(type(metadata.interactType) == "string", string.format("Invalid interactType: %s", metadata.interactType))
    assert(type(metadata.interactTypeSpecific) == "string", string.format("Invalid interactTypeSpecific: %s", metadata.interactTypeSpecific))
    assert(type(metadata.createdBy) == "string", string.format("Invalid createdBy: %s", metadata.createdBy))
    assert(type(metadata.interactRange) == "number", string.format("Invalid interactRange: %s", metadata.interactRange))
    -- assert(type(propData.metadata.resourceAmount) == "number", string.format("Invalid resourceAmount: %s", Lib.String.Format(propData.metadata.resourceAmount)))
end


Lib.Obj.CreateIntProp = function(ojbectHash, coords, metadata, spawnParams)
    metadata.interactRange = metadata.interactRange or DefaultInteractionRange
    metadata.interactType = metadata.interactType or "object"
    metadata.createdBy = metadata.createdBy or LocalPlayer.state.citizenid
    if Lib.Util.Dev then _checkPropData(metadata); end
    -- Get the ground position if needed
    if spawnParams and spawnParams.ground then
        spawnParams.visible = false
        local entity = Lib.Obj.Create(ojbectHash, coords, spawnParams)
        if entity then
            coords = GetEntityCoords(entity)
            spawnParams.rotation = GetEntityRotation(entity)
            spawnParams.ground = nil
            Lib.Obj.Delete(entity)
        end
        spawnParams.visible = nil
    end
    TriggerServerEvent("intprop:server:add", {
        objectHash = ojbectHash,
        coords = coords,
        metadata = metadata,
        spawnParams = spawnParams,
    })
end

-- DEBUG
if Lib.Util.IsDev then
    RegisterCommand("dalib_intprop_create", function(source, args, rawCommand)
        local intprop = {
            `p_haybale03x`,
            `p_cratechicken03x_anim`,
            `s_cottonbale02x`,
            `mp005_p_cs_sackcorn01x`,
            `mp005_s_mp_moonshinesack02x`,
            `mp005_s_mp_moonshinesack03x`,
            `mp005_s_mp_moonshinesack04x`,
            `p_crate03x`,
        }
        local cropTaskType = {
            [`p_crate03x`] = "Crate",
            [`p_crate03b`] = "Crate",
            [`mp005_s_mp_moonshinesack04x`] = "Sack",
            [`mp005_s_mp_moonshinesack03x`] = "Sack",
            [`mp005_s_mp_moonshinesack02x`] = "Sack",
            [`mp005_p_cs_sackcorn01x`] = "Sack",
            [`s_cottonbale02x`] = "Bale",
            [`p_haybale03x`] = "Bale",
            [`p_cratechicken03x_anim`] = "Bale",
        }
        local hash = args[1] and GetHashKey(args[1]) or intprop[math.random(#intprop)]
        local crop = args[2] and args[2] or "grain"
        local resourceAmount = args[3] and tonumber(args[3]) or 6
        local dist = math.random(10,15)/10
        local heading = math.random(100,260) + 0.0
        local coords = GetEntityCoords(PlayerPedId())
        local xOffset = -math.sin(heading * math.pi / 180.0)
        local yOffset = math.cos(heading * math.pi / 180.0)
        local vecOffset = vector3(xOffset*dist, yOffset*dist, 0)
        coords = coords + vecOffset
        local rotation = vector3(0.0, 0.0, heading)
        Lib.Obj.CreateIntProp(hash, coords, {
            createdBy = LocalPlayer.state.citizenid,
            crop = crop,
            resourceAmount = resourceAmount,
            interactTypeSpecific = cropTaskType[hash],
        }, {
            rotation = rotation,
            ground = true
        })
    end, false)

    RegisterCommand("dalib_intprop_remove", function(source, args, rawCommand)
        TriggerEvent("intprop:client:remove", {id = "item_test"})
    end, false)
end
