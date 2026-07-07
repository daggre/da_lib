local Vegmod = {}

local UID = 0 -- Starts at 1
local _getUID = function()
    UID = UID + 1
    return UID
end

Vegmod.Server = {}

local syncAllClients = function(resource, src, uid, handle, coords, opts)
    TriggerClientEvent("da_vegmod:sync:client", -1, resource, src, uid, handle, coords, opts)
end

local removeAllClients = function(resource, uid)
    TriggerClientEvent("da_vegmod:remove:client", -1, resource, uid)
end

Vegmod.add = function(resource, src, handle, coords, opts)
    local uid = _getUID()
    Vegmod.Server[uid] = {
        resource = resource,
        src = src,
        handle = handle,
        coords = coords,
        opts = opts,
    }
    return uid
end

-- Drop the record and tell every client to remove the sphere. Returns false if
-- the uid is unknown (e.g. already removed).
Vegmod.remove = function(uid)
    local entry = Vegmod.Server[uid]
    if not entry then return false end
    Vegmod.Server[uid] = nil
    removeAllClients(entry.resource, uid)
    return true
end

-- Authoritative TTL: after `ttl` ms, remove the sphere and broadcast removal.
Vegmod.expire = function(uid, ttl)
    Citizen.SetTimeout(ttl, function()
        Vegmod.remove(uid)
    end)
end

RegisterServerEvent("da_vegmod:sync:server")
---@param resource string The invoking veg modifier
---@param handle number The clientside vegModifier handle
---@param coords table The coordinates of the veg modifier
---@param opts table Veg modifer params
AddEventHandler("da_vegmod:sync:server", function(resource, handle, coords, opts)
    local src = source
    local uid = Vegmod.add(resource, src, handle, coords, opts)
    syncAllClients(resource, src, uid, handle, coords, opts)
    if opts and opts.ttl and opts.ttl > 0 then
        Vegmod.expire(uid, opts.ttl)
    end
    log.spam("da_vegmod:sync:server", {
        resource = resource,
        src = src,
        handle = handle,
        coords = coords,
        opts = opts,
        uid = uid,
    })
end)

-- Late-join catch-up: replay every sphere placed for `resource` to just the
-- requesting client. Its sync:client handler spawns the ones it's missing.
RegisterServerEvent("da_vegmod:request:server")
AddEventHandler("da_vegmod:request:server", function(resource)
    local src = source
    for uid, entry in pairs(Vegmod.Server) do
        if entry.resource == resource then
            TriggerClientEvent("da_vegmod:sync:client", src, entry.resource, entry.src, uid, entry.handle, entry.coords, entry.opts)
        end
    end
end)

_ENV.da_vegmod = Vegmod
