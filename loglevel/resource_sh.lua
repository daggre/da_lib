--- Copyright © 2024 Joshua Nelson

local ResourceName = GetCurrentResourceName()
RegisteredResource = {
    [ResourceName] = {
        callback = function(msg) print(msg) end,
        level = DefaultLogLevel,
    },
}

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

Lib.Log.SetLevel = function(resource, logLevel)
    assert(resource, ("Invalid resource '%s'."):format(resource))
    assert(RegisteredResource[resource], ("Resource '%s' is not registered."):format(resource))
    local prevLevel = RegisteredResource[resource].level
    local level = tonumber(logLevel) and tonumber(logLevel) or logLevel or DefaultLogLevel
    RegisteredResource[resource].level = level
    Lib.Log.Info(("Set log level '%s' %s->%s"):format(resource, toName(prevLevel), toName(level)))
end

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

AddEventHandler("onResourceStop", function(resourceName)
    if RegisteredResource[resourceName] then
        RegisteredResource[resourceName] = nil
    end
end)
