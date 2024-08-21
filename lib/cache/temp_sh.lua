--- Copyright © 2024 Joshua Nelson

local Cache = {}
Lib.Cache.Temp = {}

--- Add a value to the cache.
--- @param id string The ID of the cache to add the value to.
--- @param key string The key to store the value under.
--- @param value any The value to store.
--- @param warnOnCollision boolean Whether to log a warning if the key already exists in the cache.
Lib.Cache.Temp.Add = function(id, key, value, warnOnCollision)
    if not Cache[id] then Cache[id] = {}; end
    if Cache[id][key] and warnOnCollision then
        Lib.Log.Warn("TempCache index collision detected", id, key)
    end
    Cache[id][key] = value
end

--- Check if a key exists in the cache.
--- @param id string The ID of the cache to check.
--- @param key string The key to check for.
--- @return boolean boolean Whether the key exists in the cache.
Lib.Cache.Temp.Hit = function(id, key)
    if not Cache[id] then return false; end
    return Cache[id][key] ~= nil
end

--- Retrieve a value from the cache.
--- @param id string The ID of the cache to retrieve the value from.
--- @param key string The key of the value to retrieve.
--- @return any any The value, or nil if it does not exist.
Lib.Cache.Temp.Get = function(id, key)
    if not Cache[id] then return nil; end
    return Cache[id][key]
end

--- Remove a value from the cache.
--- @param id string The ID of the cache to remove the value from.
--- @param key string The key of the value to remove.
--- @return any any The removed value, or nil if it did not exist.
Lib.Cache.Temp.Remove = function(id, key)
    if not Cache[id] or not Cache[id][key] then return nil; end
    local value = Cache[id][key]
    Cache[id][key] = nil
    return value
end

--- Update a value in the cache.
--- @param id string The ID of the cache to update the value in.
--- @param key string The key of the value to update.
--- @param value any The new value.
Lib.Cache.Temp.Update = function(id, key, value)
    if not Cache[id] then return nil; end
    Cache[id][key] = value
end

--- Get number of items in the cache with id.
--- @param id any
--- @return integer
Lib.Cache.Temp.Count = function(id)
    if not Cache[id] then return 0; end
    local count = 0
    for _ in pairs(Cache[id]) do count = count + 1; end
    return count
end

if Lib.Util.IsDev then
    RegisterCommand("dalib_cache_temp_dump", function(source, args, rawCommand)
        if args[1] and Cache[args[1]] then
            Lib.Log.Debug(Cache[args[1]])
        else
            Lib.Log.Debug(Cache)
        end
    end, false)
end
