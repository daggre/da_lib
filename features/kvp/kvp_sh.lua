local KVP = {}

KVP.encode = function(key, value) SetResourceKvp(key, json.encode(value)) end
KVP.decode = function(key) return json.decode(GetResourceKvpString(key)) end
KVP.rdecode = function(resource, key) return json.decode(GetExternalKvpString(resource, key)) end
KVP.init = function(key, value)
    if KVP.decode(key) == nil then
        KVP.encode(key, value)
        return true
    end
    return false
end
KVP.rawset = function(key, value) SetResourceKvp(key, value) end
KVP.rawget = function(key) return GetResourceKvpString(key) end
KVP.rrawget = function(resource, key) return GetExternalKvpString(resource, key) end

KVP.set_string = function(key, value) SetResourceKvp(key, value) end
KVP.get_string = function(key) return GetResourceKvpString(key) end
KVP.rget_string = function(resource, key) GetExternalKvpString(resource, key) end

KVP.get_int = function(key) return GetResourceKvpInt(key) end
KVP.set_int = function(key, value) SetResourceKvpInt(key, value) end
KVP.rget_int = function(resource, key) GetExternalKvpInt(resource, key) end

KVP.get_float = function(key) return GetResourceKvpFloat(key) end
KVP.set_float = function(key, value) SetResourceKvpFloat(key, value) end
KVP.rget_float = function(resource, key) GetExternalKvpFloat(resource, key) end

KVP.delete = function(key) DeleteResourceKvp(key) end

KVP.search = function(prefix)
    local keys = {}
    local handle = StartFindKvp(prefix)
    while true do
        local kvp = FindKvp(handle)
        if not kvp then break; end
        table.insert(keys, kvp)
    end
    EndFindKvp(handle)
    table.sort(keys)
    return keys
end
KVP.rsearch = function(resource, prefix)
    local keys = {}
    local handle = StartFindExternalKvp(resource, prefix)
    while true do
        local kvp = FindKvp(handle)
        if not kvp then break; end
        table.insert(keys, kvp)
    end
    EndFindKvp(handle)
    table.sort(keys)
    return keys
end

KVP.flush = function() Citizen.InvokeNative(0xE27C97A0) end

_ENV.kvp = KVP

AddEventHandler("kvp:delete", function(resourceName, key)
    if GetCurrentResourceName() ~= resourceName then return; end
    KVP.delete(key)
    log.debug("Deleted KVP key: " .. key)
end)
