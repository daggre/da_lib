--- Copyright © 2024 Joshua Nelson

local ClientCallbacks = {}
local ClientCallbackEvents = {}

--- Client Callbacks ---
-- Trigger a registered callback on the client from the server
RegisterNetEvent("ClientCallback:Async")
AddEventHandler("ClientCallback:Async", function(eventName, ...)
    -- Check if the eventName is registered
    if (ClientCallbacks[eventName] ~= nil) then
        -- Trigger the callback
        ClientCallbacks[eventName](...)
    end
end)

-- Trigger a blocking client callback
RegisterNetEvent("ClientCallback:Blocking")
AddEventHandler("ClientCallback:Blocking", function(eventName, callbackId, ...)
    -- Check if the eventName is registered
    if (ClientCallbacks[eventName] ~= nil) then
        -- Trigger the callback and get the result
        local result = { ClientCallbacks[eventName](...) }
        -- Get the callback event id to respond to the server with the correct id
        local callbackEvent = GetCallbackEventId(eventName, tostring(callbackId))
        -- Send the result back to the server
        TriggerServerEvent("ClientCallback:Blocking:Return", callbackEvent, result)
    end
end)

---Register a client callback
---@param eventName string The event name to register
---@param callback function The callback function to call
Lib.Net.RegisterClientCb = function(eventName, callback)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(callback ~= nil, "TypeError: callback is \"nil\".")
    -- Register the callback
    ClientCallbacks[eventName] = callback
end

--- Server Callbacks ---
-- Store the return data from the server so the blocking thread can access it
RegisterNetEvent("ServerCallback:Blocking:Return")
AddEventHandler("ServerCallback:Blocking:Return", function(callbackEvent, data)
    assert(callbackEvent ~= nil and type(callbackEvent) == "string", "TypeError: callbackEvent is not type: \"string\".")

    -- Check that the callback event is registered
    if (ClientCallbackEvents[callbackEvent] ~= nil) then
        -- Store the data for the blocking thread
        ClientCallbackEvents[callbackEvent] = data
    end
end)

---Send a request to the server and block until the server responds or timeout
---@param eventName string The event name to call
---@param timeout integer The timeout in milliseconds to wait for the server response
---@param ... unknown Parameters sent to the server in the server event
---@return unknown|nil callbackResult The returned data from the server event
Lib.Net.BlockingCb = function(eventName, timeout, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(timeout ~= nil and type(timeout) == "number", "TypeError: timeout is not type: \"number\".")

    -- Get a unique callback id
    local callbackId = GetUniqueCallbackId()
    -- Combine the event name and callback id to get a unique event id
    local callbackEventId = GetCallbackEventId(eventName, callbackId)
    local callbackResult = nil

    -- Register the event id as waiting
    ClientCallbackEvents[callbackEventId] = EventStatus.waiting
    -- Trigger the server event and send our event id with the params
    TriggerServerEvent("ServerCallback:Blocking", eventName, callbackId, ...)

    -- Wait for the server to respond
    WaitOnBlockingCallbackEvent(ClientCallbackEvents, callbackEventId, timeout)
    -- If the server did not respond or timed out return nil
    if ClientCallbackEvents[callbackEventId] == EventStatus.timeout or ClientCallbackEvents[callbackEventId] == EventStatus.none then
        return nil
    end

    -- Get the result that was stored when the server responded
    callbackResult = ClientCallbackEvents[callbackEventId]
    -- Clear the event id
    ClientCallbackEvents[callbackEventId] = nil
    -- Unpack the result and return it
    return table.unpack(callbackResult)
end

---Send a request to the server and do not block
---@param eventName string The event name to call
---@param ... unknown|nil Parameters sent to the server in the server event
Lib.Net.AsyncCb = function(eventName, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    TriggerServerEvent("ServerCallback:Async", eventName, ...)
end

---Trigger a server callback and wait for the response
---@param eventName string The regsistered event name to call
---@param ... unknown Parameters sent to the server in the server event
---@return unknown|nil callbackResult The returned data from the server event
Lib.Net.TriggerServerCallback = function(eventName, ...)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    -- Trigger the server event with a default 3 sec timeout
    return Lib.Net.BlockingCb(eventName, 3000, ...)
end

--- Export these functions to the global scope
exports('RegisterClientCb', Lib.Net.RegisterClientCb)
exports('BlockingCb', Lib.Net.BlockingCb)
exports('AsyncCb', Lib.Net.AsyncCb)
