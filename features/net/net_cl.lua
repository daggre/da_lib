local UID = 0
local EVENT_TIMEOUT = "timeout"
local EVENT_WAITING = true

local ClientEvent = {}
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

local TriggerBlockingServerEvent = function(event, timeout, ...)
    local uid = tostring(_getUID())
    local eid = event .. "_" .. uid

    Event[eid] = EVENT_WAITING
    TriggerServerEvent("ServerEvent:Blocking", event, uid, ...)
    _wait(eid, timeout)

    if Event[eid] == EVENT_TIMEOUT or Event[eid] == nil then
        return nil
    end

    local result = Event[eid]
    Event[eid] = nil

    return table.unpack(result)
end

local RegisterBlockingClientEvent = function(event, fn)
    assert(event ~= nil and type(event) == "string", "TypeError: event is not type: \"string\".")
    assert(fn ~= nil and (type(fn) == "function" or (type(fn) == "table" and fn['__cfx_functionReference'])), "TypeError: callback is not type: \"function\".")
    assert(ClientEvent[event] == nil, "Error: event already registered.")

    ClientEvent[event] = fn
end

_ENV.RegisterBlockingClientEvent = RegisterBlockingClientEvent
_ENV.TriggerBlockingServerEvent = TriggerBlockingServerEvent

RegisterNetEvent("ClientEvent:Blocking")
AddEventHandler("ClientEvent:Blocking", function(event, uid, ...)
    if (ClientEvent[event] ~= nil) then
        local result = { ClientEvent[event](...) }
        TriggerServerEvent("ClientEvent:Blocking:Return", event .. "_" .. uid, result)
    end
end)

RegisterNetEvent("ServerEvent:Blocking:Return")
AddEventHandler("ServerEvent:Blocking:Return", function(event, data)
    if (Event[event] ~= nil) then
        Event[event] = data
    end
end)

local Net = {}

Net.event = function(event, fn)
    AddEventHandler(event, fn)
end

Net.events = function(events)
    for event, fn in pairs(events) do
        AddEventHandler(event, fn)
    end
end

_ENV.da_net = Net


-- ServerId (aka source)
-- MyClient     -- GetPlayerServerId(PlayerId())
-- OtherClient  -- GetPlayerServerId(NetworkGetPlayerIndexFromPed(<entity>))
-- Server       -- source

-- NetId (aka the thing in square brackets)
-- MyClient     -- NetworkGetNetworkIdFromEntity(PlayerPedId())
-- OtherClient  -- NetworkGetNetworkIdFromEntity(<entity>)
-- Server       -- NA?

-- PlayerId (aka the thing in squirly {16}, aka Player Index)
-- MyClient     -- PlayerId()
-- OtherClient  -- NA
-- Server       -- NA

-- Entity (6 digit number correspondign to clientside object)
-- MyClient     -- PlayerPedId()
-- OtherClient  -- NetworkGetEntityFromNetworkId(<netid>)
-- Server       -- NA?
