--- Copyright © 2024 Joshua Nelson

local ZoneCacheId = "ppZone"
local PropCacheId = "ppProp"
local DefaultZoneRange = 60
local DefaultInteractionRange = 1.9

local CreateProp = function(data)
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id) or Lib.Cache.Temp.Hit(PropCacheId, data.id) then return; end
    data.spawnParams = data.spawnParams or {}

    Lib.Log.Debug("Creating polyprop:", data)
    local entity = Lib.Obj.Create(data.objectHash, data.coords, data.spawnParams)
    if data.objectHash == `p_bucket03x` and data.resourceAmount then
        Lib.Obj.SetExpression(entity, "bucket_Fill", data.resourceAmount)
        Lib.Log.DebugVerbose("Creating bucket, setting resource amount to "..tostring(data.resourceAmount))
    end
    Lib.Cache.Temp.Add(PropCacheId, data.id, entity, true)
end

local DeleteProp = function(id)
    local entity = Lib.Cache.Temp.Get(PropCacheId, id)
    Lib.Obj.Delete(entity)
    Lib.Cache.Temp.Remove(PropCacheId, id)
end

local AddInteractivePropZone = function(data)
    if data.metadata.interactRange == nil then return; end
    Lib.Log.Debug("Adding PolyProp InteractivePropZone", data)
    -- data.intId = data.id.."_int"
    -- data.interactType = "object"
    assert(data.metadata and data.metadata.interactType ~= nil, "Missing interactType")
    assert(data.metadata and data.metadata.interactTypeSpecific ~= nil, "Missing interactTypeSpecific")
    -- data.print = Lib.Util.IsDev and DebugPolyProps or false
    local zone = Lib.PolyZone.Circle(
        "pprop_int",
        data.coords,
        data.metadata and data.metadata.interactRange or DefaultInteractionRange,
        {
            data = data,
            debugColor = { 200, 0, 255 },
            useZ = true,
        })
    Lib.Cache.Temp.Add(ZoneCacheId, data.id.."_int", zone, true)
end

Lib.PolyZone.EnterHandler("pprop_int", function(data)
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id.."_int") then return; end
    TriggerEvent("interactionZone:enter", data)
end)

Lib.PolyZone.ExitHandler("pprop_int", function(data)
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id.."_int") then return; end
    TriggerEvent("interactionZone:exit", data)
end)

local AddPropZone = function(data)
    local zoneRange = DefaultZoneRange
    local zone = Lib.PolyZone.Circle("pprop", data.coords, zoneRange, {
        data = data,
        debugColor = { 155, 0, 255 }
    })
    Lib.Cache.Temp.Add(ZoneCacheId, data.id, zone, true)
    AddInteractivePropZone(data)
end

Lib.PolyZone.EnterHandler("pprop", function(data)
    CreateProp(data)
end)

Lib.PolyZone.ExitHandler("pprop", function(data)
    DeleteProp(data.id)
end)

local RemoveProp = function(data)
    if not Lib.Cache.Temp.Hit(ZoneCacheId, data.id) then return; end
    Lib.Log.Debug("Removing PolyProp PropZone", data)
    DeleteProp(data.id)
    Lib.Cache.Temp.Remove(ZoneCacheId, data.id)
    Lib.Cache.Temp.Remove(ZoneCacheId, data.id.."_int")
    TriggerEvent("interactionZone:exit", data)
end

local AddProp = function(propData)
    assert(type(propData.objectHash) == "number", string.format("Invalid prop: %s", Lib.String.Format(propData.objectHash)))
    assert(type(propData.coords) == "vector3", string.format("Invalid coords: %s", Lib.String.Format(propData.coords)))
    RemoveProp({id = propData.id})
    AddPropZone(propData)
end

RegisterNetEvent("polyprops:client:add")
AddEventHandler("polyprops:client:add", function(data)
    AddProp(data)
end)

RegisterNetEvent("polyprops:client:remove")
AddEventHandler("polyprops:client:remove", function(data)
    RemoveProp(data)
end)

Lib.Obj.CreatePolyProp = function(ojbectHash, coords, metadata, spawnParams)
    assert(type(ojbectHash) == "number", string.format("Invalid prop: %s", Lib.String.Format(ojbectHash)))
    assert(type(coords) == "vector3", string.format("Invalid coords: %s", Lib.String.Format(coords)))
    assert(type(metadata) == "table", string.format("Invalid metadata: %s", Lib.String.Format(metadata)))
    metadata.interactRange = metadata.interactRange or DefaultInteractionRange
    metadata.interactType = metadata.interactType or "object"
    metadata.createdBy = metadata.createdBy or LocalPlayer.state.citizenid
    -- assert(type(metadata.id) == "string", string.format("Invalid id: %s", Lib.String.Format(metadata.id)))
    assert(type(metadata.interactTypeSpecific) == "string", string.format("Invalid interactTypeSpecific: %s", Lib.String.Format(metadata.interactTypeSpecific)))
    assert(type(metadata.crop) == "string", string.format("Invalid crop: %s", Lib.String.Format(metadata.crop)))
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
    TriggerServerEvent("polyprops:server:add", {
        objectHash = ojbectHash,
        coords = coords,
        metadata = metadata,
        spawnParams = spawnParams,
    })
end

-- DEBUG
if Lib.Util.IsDev then
    RegisterCommand("pprop_add", function(source, args, rawCommand)
        local polyprops = {
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
        local hash = args[1] and GetHashKey(args[1]) or polyprops[math.random(#polyprops)]
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
        Lib.Obj.CreatePolyProp(hash, coords, {
            createdBy = LocalPlayer.state.citizenid,
            crop = crop,
            resourceAmount = resourceAmount,
            interactTypeSpecific = cropTaskType[hash],
        }, {
            rotation = rotation,
            ground = true
        })
    end, false)

    RegisterCommand("pprop_rem", function(source, args, rawCommand)
        TriggerEvent("polyprops:client:remove", {id = "item_test"})
    end, false)
end
