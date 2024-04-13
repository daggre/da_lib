--- Copyright © 2024 Joshua Nelson

EventStatus = {
    none = nil,
    timeout = "timeout",
    waiting = true,
}
NextCallbackId = 0
MaxCallbackId = 2^16


---GetCallbackEventId
---@param eventName string
---@param callbackId string
---@return string
GetCallbackEventId = function(eventName, callbackId)
    assert(eventName ~= nil and type(eventName) == "string", "TypeError: eventName is not type: \"string\".")
    assert(callbackId ~= nil and type(callbackId) == "string", "TypeError: callbackId is not type: \"string\".")
    return eventName .. "_" .. callbackId
end

---GetCallbackId
---@return string callbackId
GetUniqueCallbackId = function()
    local callbackId = tostring(NextCallbackId)
    NextCallbackId = (NextCallbackId >= MaxCallbackId) and 0 or NextCallbackId + 1
    return callbackId
end

---WaitOnCallbackEvent
---@param callbackEvents table
---@param callbackEvent string
---@param timeout number
WaitOnBlockingCallbackEvent = function(callbackEvents, callbackEvent, timeout)
    local startTime = GetGameTimer()
    while callbackEvents[callbackEvent] == EventStatus.waiting do
        Citizen.Wait(0)
        if (GetGameTimer() >= startTime + timeout) then
            callbackEvents[callbackEvent] = EventStatus.timeout
        end
    end
end

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
