--- Copyright © 2024 Joshua Nelson

local ServerCallbacks = {}
local CallbackEvents = {}

--- Client Callbacks ---
-- Store the return data from the client so the blocking thread can access it
RegisterNetEvent("ClientCallback:Blocking:Return")
AddEventHandler("ClientCallback:Blocking:Return", function(callbackEvent, data)
    assert(callbackEvent ~= nil and type(callbackEvent) == "string", "TypeError: callbackEvent is not type: \"string\".")

    if (CallbackEvents[callbackEvent] ~= nil) then
        CallbackEvents[callbackEvent] = data
    end
end)

---Make a blocking client call
---@param eventName string The event name to call
---@param source integer The source client id of the event
---@param timeout integer The timeout in milliseconds to wait for the client response
---@param ... unknown Parameters sent to the client in the client event
---@return nil callbackResult The returned data from the client event
Lib.Net.BlockingClientCb = function(eventName, source, timeout, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(source ~= nil and type(source) == "number", "TypeError: source is not type: \"number\".")
    assert(timeout ~= nil and type(timeout) == "number", "TypeError: timeout is not type: \"number\".")

    local src = source
    -- Get a unique callback id
    local callbackId = GetUniqueCallbackId()
    -- Get the callback event id
    local callbackEventId = GetCallbackEventId(eventName, callbackId)
    local callbackResult = nil

    -- Register the event id and set the callback event to waiting
    CallbackEvents[callbackEventId] = EventStatus.waiting
    -- Trigger the client event, sending the callback id
    TriggerClientEvent("ClientCallback:Blocking", src, eventName, callbackId, ...)

    -- Wait for the client to respond or timeout
    WaitOnBlockingCallbackEvent(CallbackEvents, callbackEventId, timeout)
    -- If the event timed out or none, return nil
    if CallbackEvents[callbackEventId] == EventStatus.timeout or CallbackEvents[callbackEventId] == EventStatus.none then
        return nil
    end

    -- Get the stored result from the client response
    callbackResult = CallbackEvents[callbackEventId]
    -- Set the event to none
    CallbackEvents[callbackEventId] = nil
    -- Unpack the result and return it
    return table.unpack(callbackResult)
end

---Trigger a client event asynchronously
---@param eventName any
---@param source any
---@param ... unknown
Lib.Net.AsyncClientCb = function(eventName, source, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(source ~= nil and type(source) == "number", "TypeError: source is not type: \"number\".")
    local src = source

    -- Trigger the client event
    TriggerClientEvent("ClientCallback:Async", src, eventName, ...)
end

--- Server Callbacks ---
-- Call the registered server callback function and return the result
RegisterNetEvent("ServerCallback:Blocking")
AddEventHandler("ServerCallback:Blocking", function(eventName, callbackId, ...)
    local src = source
    -- Check if the callback is registered
    if (ServerCallbacks[eventName] ~= nil) then
        -- Call the callback and store the result
        local result = { ServerCallbacks[eventName](src, ...) }
        -- Get the callback event id
        local callbackEventId = GetCallbackEventId(eventName, tostring(callbackId))
        -- Send the result to the client
        TriggerClientEvent("ServerCallback:Blocking:Return", src, callbackEventId, result)
    end
end)

-- Call the registered asynchronous server callback
RegisterNetEvent("ServerCallback:Async")
AddEventHandler("ServerCallback:Async", function(eventName, ...)
    local src = source
    -- Check if the callback is registered
    if (ServerCallbacks[eventName] ~= nil) then
        ServerCallbacks[eventName](src, ...)
    end
end)

---Register a server callback
---@param eventName string The event name to register
---@param callback any The callback function to call
Lib.Net.RegisterServerCb = function(eventName, callback)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(callback ~= nil, "TypeError: callback is \"nil\".")
    ServerCallbacks[eventName] = callback
end

-- Export the functions to the global scope
exports('RegisterServerCb', Lib.Net.RegisterServerCb)
exports('BlockingClientCb', Lib.Net.BlockingClientCb)
exports('AsyncClientCb', Lib.Net.AsyncClientCb)
