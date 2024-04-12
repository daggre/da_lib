local ServerCallbacks = {}
local CallbackEvents = {}

--- Client Callbacks ---
RegisterNetEvent("ClientCallback:Blocking:Return")
AddEventHandler("ClientCallback:Blocking:Return", function(callbackEvent, data)
    assert(callbackEvent ~= nil and type(callbackEvent) == "string", "TypeError: callbackEvent is not type: \"string\".")

    if (CallbackEvents[callbackEvent] ~= nil) then
        CallbackEvents[callbackEvent] = data
    end
end)

Lib.Net.BlockingClientCb = function(eventName, source, timeout, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(source ~= nil and type(source) == "number", "TypeError: source is not type: \"number\".")
    assert(timeout ~= nil and type(timeout) == "number", "TypeError: timeout is not type: \"number\".")

    local src = source
    local callbackId = GetUniqueCallbackId()
    local callbackEventId = GetCallbackEventId(eventName, callbackId)
    local callbackResult = nil

    CallbackEvents[callbackEventId] = EventStatus.waiting
    TriggerClientEvent("ClientCallback:Blocking", src, eventName, callbackId, ...)

    WaitOnBlockingCallbackEvent(CallbackEvents, callbackEventId, timeout)
    if CallbackEvents[callbackEventId] == EventStatus.timeout or CallbackEvents[callbackEventId] == EventStatus.none then
        return nil
    end

    callbackResult = CallbackEvents[callbackEventId]
    CallbackEvents[callbackEventId] = nil
    return table.unpack(callbackResult)
end

Lib.Net.AsyncClientCb = function(eventName, source, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(source ~= nil and type(source) == "number", "TypeError: source is not type: \"number\".")

    local src = source

    TriggerClientEvent("ClientCallback:Async", src, eventName, ...)
end

--- Server Callbacks ---
RegisterNetEvent("ServerCallback:Blocking")
AddEventHandler("ServerCallback:Blocking", function(eventName, callbackId, ...)
    local src = source
    if (ServerCallbacks[eventName] ~= nil) then
        local result = { ServerCallbacks[eventName](src, ...) }
        local callbackEventId = GetCallbackEventId(eventName, tostring(callbackId))
        TriggerClientEvent("ServerCallback:Blocking:Return", src, callbackEventId, result)
    end
end)

RegisterNetEvent("ServerCallback:Async")
AddEventHandler("ServerCallback:Async", function(eventName, ...)
    local src = source
    if (ServerCallbacks[eventName] ~= nil) then
        ServerCallbacks[eventName](src, ...)
    end
end)

Lib.Net.RegisterServerCb = function(eventName, callback)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(callback ~= nil, "TypeError: callback is \"nil\".")
    ServerCallbacks[eventName] = callback
end

exports('RegisterServerCb', Lib.Net.RegisterServerCb)
exports('BlockingClientCb', Lib.Net.BlockingClientCb)
exports('AsyncClientCb', Lib.Net.AsyncClientCb)
