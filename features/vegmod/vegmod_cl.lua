local _ADD_VEG_MOD_SPHERE = 0xFA50F79257745E74 -- AddVegModifierSphere
local _REMOVE_VEG_MOD_SPHERE = 0x9CF1836C03FB67A2 -- RemoveVegModifierSphere
local PENDING = -1
local LOCAL = 0

local Vegmod = {}

Vegmod.Resource = GetCurrentResourceName()
Vegmod.Client = {}
Vegmod.Server = {}

Vegmod.Flags = {
    { value = (1<<0), name = "DEBRIS", note = "" },
    { value = (1<<1), name = "GRASS", note = "" },
    { value = (1<<2), name = "BUSH", note = "" },
    { value = (1<<3), name = "WEED", note = "" },
    { value = (1<<4), name = "FLOWER", note = "" },
    { value = (1<<5), name = "SAPLING", note = "" },
    { value = (1<<6), name = "TREE", note = "" },
    { value = (1<<7), name = "ROCK", note = "" },
    { value = (1<<8), name = "LONGGRASS", note = "" },
}

Vegmod.Type = {
    { value = (1<<0), name = "VMT_Cull", note = "" },
    { value = (1<<1), name = "VMT_Flatten", note = "" },
    { value = (1<<2), name = "VMT_FlattenDeepSurface", note = "" },
    { value = (1<<3), name = "VMT_Explode", note = "" },
    { value = (1<<4), name = "VMT_Push", note = "" },
    { value = (1<<5), name = "VMT_Decal", note = "" },
}

for _, f in ipairs(Vegmod.Flags) do
    Vegmod.Flags[f.name] = f.value
end
Vegmod.Flags.Default = Vegmod.Flags.BUSH + Vegmod.Flags.WEED + Vegmod.Flags.FLOWER + Vegmod.Flags.SAPLING

for _, t in ipairs(Vegmod.Type) do
    Vegmod.Type[t.name] = t.value
end
Vegmod.Type.Default = Vegmod.Type.VMT_Cull

local syncToServer = function(handle, coords, opts)
    TriggerServerEvent("da_vegmod:sync:server", Vegmod.Resource, handle, coords, opts)
end

local syncClient = function(coords, opts)
    opts = opts or {}
    opts.radius = opts.radius or 3.0
    opts.flags = opts.flags or Vegmod.Flags.Default
    if opts.network == nil then opts.network = true end
    opts.modType = opts.modType or Vegmod.Type.Default
    local vegModHandle = Citizen.InvokeNative(_ADD_VEG_MOD_SPHERE, coords, opts.radius, opts.modType, opts.flags, 0) -- AddVegModifierSphere
    local uid = opts.network and PENDING or LOCAL
    Vegmod.Client[vegModHandle] = {
        uid = uid,
        coords = coords,
        radius = opts.radius,
        modType = opts.modType,
        flags = opts.flags,
    }
    return vegModHandle
end

Vegmod.add = function(coords, opts)
    local handle = syncClient(coords, opts)
    if opts.network then syncToServer(handle, coords, opts) end
    return handle
end

Vegmod.remove = function(handle)
    if not handle then return end
    Citizen.InvokeNative(_REMOVE_VEG_MOD_SPHERE, Citizen.PointerValueIntInitialized(handle), 0) -- RemoveVegModifierSphere
end

-- Remove every sphere this client has spawned; returns how many were cleared.
Vegmod.clear = function()
    local count = 0
    for handle in pairs(Vegmod.Client) do
        Vegmod.remove(handle)
        count = count + 1
    end
    Vegmod.Client = {}
    Vegmod.Server = {}
    return count
end

-- Networked sphere that the SERVER removes (and broadcasts removal for) after
-- `seconds`. The timer is authoritative on the server; the ttl travels in opts.
Vegmod.timed = function(coords, seconds, opts)
    opts = opts or {}
    opts.network = true
    opts.ttl = math.floor((seconds or 120) * 1000)
    return Vegmod.add(coords, opts)
end

-- Remove a synced sphere by its server uid, cleaning both lookup tables.
local removeByUid = function(uid)
    local handle = Vegmod.Server[uid]
    if not handle then return false end
    Vegmod.remove(handle)
    Vegmod.Client[handle] = nil
    Vegmod.Server[uid] = nil
    return true
end

RegisterNetEvent("da_vegmod:sync:client")
AddEventHandler("da_vegmod:sync:client", function(res, source, uid, handle, coords, opts)
    if res ~= Vegmod.Resource then return end
    if Vegmod.Server[uid] then return end -- already have this uid (duplicate / catch-up replay)
    log.spam({
        sid = source,
        uid = uid,
        handle = handle,
        coords = coords,
        opts = opts,
    })
    local serverId = GetPlayerServerId(PlayerId())
    if not Vegmod.Client[handle] or (Vegmod.Client[handle].uid ~= uid and Vegmod.Client[handle].uid ~= PENDING) then
        if serverId == source then
            log.warn(("vegModifier handle (%s) desync, generating new handle"):format(handle))
        end
        handle = syncClient(coords, opts)
    end
    if Vegmod.Client[handle].uid ~= PENDING then
        log.error(("vegModifer handle (%s) collision: Overwriting %s"):format(handle, Vegmod.Client[handle]))
    end
    Vegmod.Client[handle].uid = uid
    Vegmod.Server[uid] = handle
end)

-- Server-issued removal (e.g. a timed sphere expiring). Resource-scoped like sync.
RegisterNetEvent("da_vegmod:remove:client")
AddEventHandler("da_vegmod:remove:client", function(res, uid)
    if res ~= Vegmod.Resource then return end
    removeByUid(uid)
end)

-- Ask the server for every sphere already placed for this resource; the server
-- replays them via da_vegmod:sync:client and we spawn the ones we're missing.
Vegmod.request = function()
    TriggerServerEvent("da_vegmod:request:server", Vegmod.Resource)
end

-- Late-join / resource-restart catch-up. Self-contained (no da_game dependency)
-- so any resource that includes da_vegmod syncs on its own. Fires once we're in
-- the session; on a mid-game restart NetworkIsPlayerActive is already true.
Citizen.CreateThread(function()
    while NetworkIsPlayerActive(PlayerId()) ~= 1 do Citizen.Wait(250) end
    Vegmod.request()
end)

_ENV.da_vegmod = Vegmod

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == Vegmod.Resource then
        Vegmod.clear()
    end
end)
