--- Copyright © 2024 Joshua Nelson

local ResourceName = GetCurrentResourceName()

---Track the registered resources, their log level and the callback function
RegisteredResource = {
    [ResourceName] = {
        callback = function(msg) print(msg) end,
        level = DefaultLogLevel,
    },
}

---Convert a log level to a name
---@param level string|number log level
---@return string|nil levelName log level name
local toName = function(level)
    if level == nil then return nil; end
    if type(level) == "string" then return level; end
    if type(level) == "number" then
        for name, logLevel in pairs(Level) do
            if logLevel.level == level then return name; end
        end
    end
    return nil
end

---Set the log level for a resource
---@param resource string resource name
---@param logLevel number|string|nil log level
Lib.Log.SetLevel = function(resource, logLevel)
    assert(resource, ("Invalid resource '%s'."):format(resource))
    assert(RegisteredResource[resource], ("Resource '%s' is not registered."):format(resource))
    local prevLevel = RegisteredResource[resource].level
    local level = tonumber(logLevel) and tonumber(logLevel) or logLevel or DefaultLogLevel
    RegisteredResource[resource].level = level
    Lib.Log.Info(("Set log level '%s' %s->%s"):format(resource, toName(prevLevel), toName(level)))
end

---Register a resource with the logger
---@param callback function The callback function to be called whenever we log
---@param logLevel string|integer|nil The initial log level for the resource
Lib.Log.Register = function(callback, logLevel)
    local resource = GetInvokingResource()
    assert(resource, ("Invalid resource: %s"):format(resource))
    if logLevel and not tonumber(logLevel) and not Level[logLevel] then
        print(("Invalid log level: %s"):format(logLevel))
        logLevel = nil
    end
    if logLevel == nil then logLevel = DefaultLogLevel; end
    RegisteredResource[resource] = { level = logLevel, callback = callback }
    Lib.Log.Debug(("Registered resource '%s' log level (%s)"):format(resource, logLevel))
end

---Event Handler for onResourceStop event which invalidates a resources
---registered data if that resource was stopped
---@param resourceName string The resource that was stopped
AddEventHandler("onResourceStop", function(resourceName)
    if RegisteredResource[resourceName] then
        RegisteredResource[resourceName] = nil
    end
end)
