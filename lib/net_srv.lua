local UID = 0
local EVENT_TIMEOUT = "timeout"
local EVENT_WAITING = true

local ServerEvent = {}
local Event = {}

local _getUID = function()
    UID = UID + 1
    return UID
end

local _wait = function(eid, timeout)
    local endTime = GetGameTimer() + timeout
    while Event[eid] == EVENT_WAITING do
        Citizen.Wait(0)
        if GetGameTimer() >= endTime then
            Event[eid] = EVENT_TIMEOUT
        end
    end
end

local TriggerBlockingClientEvent = function(event, source, timeout, ...)
    local src = source
    local uid = tostring(_getUID())
    local eid = event .. "_" .. uid

    Event[eid] = EVENT_WAITING
    TriggerClientEvent("ClientEvent:Blocking", src, event, uid, ...)
    _wait(eid, timeout)

    if Event[eid] == EVENT_TIMEOUT or Event[eid] == nil then
        return nil
    end

    local result = Event[eid]
    Event[eid] = nil

    return table.unpack(result)
end

local RegisterBlockingServerEvent = function(event, fn)
    assert(event ~= nil and type(event) == "string", "TypeError: event is not type: \"string\".")
    assert(fn ~= nil and (type(fn) == "function" or (type(fn) == "table" and fn['__cfx_functionReference'])), "TypeError: callback is not type: \"function\".")
    assert(ServerEvent[event] == nil, "Error: event already registered.")

    ServerEvent[event] = fn
end

_ENV.RegisterBlockingServerEvent = RegisterBlockingServerEvent
_ENV.TriggerBlockingClientEvent = TriggerBlockingClientEvent

RegisterNetEvent("ServerEvent:Blocking")
AddEventHandler("ServerEvent:Blocking", function(event, uid, ...)
    local src = source
    if (ServerEvent[event] ~= nil) then
        local result = { ServerEvent[event](src, ...) }
        TriggerClientEvent("ServerEvent:Blocking:Return", src, event .. "_" .. uid, result)
    end
end)

RegisterNetEvent("ClientEvent:Blocking:Return")
AddEventHandler("ClientEvent:Blocking:Return", function(event, data)
    if (Event[event] ~= nil) then
        Event[event] = data
    end
end)
