--- Copyright © 2024 Joshua Nelson

local ClientCallbacks = {}
local ClientCallbackEvents = {}

--- Client Callbacks ---
RegisterNetEvent("ClientCallback:Async")
AddEventHandler("ClientCallback:Async", function(eventName, ...)
    if (ClientCallbacks[eventName] ~= nil) then
        ClientCallbacks[eventName](...)
    end
end)

RegisterNetEvent("ClientCallback:Blocking")
AddEventHandler("ClientCallback:Blocking", function(eventName, callbackId, ...)
    if (ClientCallbacks[eventName] ~= nil) then
        local result = { ClientCallbacks[eventName](...) }
        local callbackEvent = GetCallbackEventId(eventName, tostring(callbackId))
        TriggerServerEvent("ClientCallback:Blocking:Return", callbackEvent, result)
    end
end)

Lib.Net.RegisterClientCb = function(eventName, callback)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(callback ~= nil, "TypeError: callback is \"nil\".")
    ClientCallbacks[eventName] = callback
end

--- Server Callbacks ---
RegisterNetEvent("ServerCallback:Blocking:Return")
AddEventHandler("ServerCallback:Blocking:Return", function(callbackEvent, data)
    assert(callbackEvent ~= nil and type(callbackEvent) == "string", "TypeError: callbackEvent is not type: \"string\".")

    if (ClientCallbackEvents[callbackEvent] ~= nil) then
        ClientCallbackEvents[callbackEvent] = data
    end
end)

Lib.Net.BlockingCb = function(eventName, timeout, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(timeout ~= nil and type(timeout) == "number", "TypeError: timeout is not type: \"number\".")

    local callbackId = GetUniqueCallbackId()
    local callbackEventId = GetCallbackEventId(eventName, callbackId)
    local callbackResult = nil

    ClientCallbackEvents[callbackEventId] = EventStatus.waiting
    TriggerServerEvent("ServerCallback:Blocking", eventName, callbackId, ...)

    WaitOnBlockingCallbackEvent(ClientCallbackEvents, callbackEventId, timeout)
    if ClientCallbackEvents[callbackEventId] == EventStatus.timeout or ClientCallbackEvents[callbackEventId] == EventStatus.none then
        return nil
    end

    callbackResult = ClientCallbackEvents[callbackEventId]
    ClientCallbackEvents[callbackEventId] = nil
    return table.unpack(callbackResult)
end

Lib.Net.AsyncCb = function(eventName, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    TriggerServerEvent("ServerCallback:Async", eventName, ...)
end

Lib.Net.TriggerServerCallback = function(eventName, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    return Lib.Net.BlockingCb(eventName, 3000, ...)
end

exports('RegisterClientCb', Lib.Net.RegisterClientCb)
exports('BlockingCb', Lib.Net.BlockingCb)
exports('AsyncCb', Lib.Net.AsyncCb)
