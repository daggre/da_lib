--- Copyright © 2024 Joshua Nelson

local LazyCache = {}
DefaultTimeout = 10000
Lib.Cache.Lazy = {}

--- Register a new item in the cache
--- @param id string The ID of the item
--- @param name string The name of the item
--- @param fn function The function to compute the value of the item
--- @param timeout number The timeout for the item
Lib.Cache.Lazy.Register = function(id, name, fn, timeout)
    if not LazyCache[id] then LazyCache[id] = {}; end
    LazyCache[id][name] = { fn = fn, timeout = timeout }
end

--- Get the value of an item from the cache
--- @param id string The ID of the item
--- @param name string The name of the item
--- @vararg any Additional arguments to pass to the item's function if it needs to be called
--- @return any any The value of the item
Lib.Cache.Lazy.Get = function(id, name, ...)
    if LazyCache[id] == nil or LazyCache[id][name] == nil then return nil; end

    if LazyCache[id][name].value == nil or LazyCache[id][name].expires < GetGameTimer() then
        local timeout = LazyCache[id][name].timeout or DefaultTimeout
        LazyCache[id][name].value = LazyCache[id][name].fn(...)
        LazyCache[id][name].expires = GetGameTimer() + timeout
    end

    return LazyCache[id][name].value
end

--- Set a delay using a unique id and name that returns true if the delay was initiated and false if it was already running
--- @param id string The ID of the item
--- @param name string The name of the item
--- @param timeout number The timeout for the delay
--- @return boolean boolean Whether the delay was started (true) or not (false)
Lib.Cache.Lazy.Delay = function(id, name, timeout)
    if not LazyCache[id] then LazyCache[id] = {}; end
    if not LazyCache[id][name] then LazyCache[id][name] = {}; end

    if not LazyCache[id][name].delay then
        LazyCache[id][name].delay = true
        Citizen.SetTimeout(timeout or DefaultTimeout, function()
            LazyCache[id][name].delay = nil
        end)
        return true
    end
    return false
end
