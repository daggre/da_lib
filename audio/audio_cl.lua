--- Copyright © 2024 Joshua Nelson

local AudioStreams = {}

---Play a stream from an entity
---@param entity integer The entity to play the stream from
---@param streamName string The name of the stream to play
---@param soundSet string|integer The sound set to play
---@return integer streamId The stream id of the audio stream
local function PlayStream(entity, streamName, soundSet)
    soundSet = tostring(soundSet)
    local timeout = 0
    while not LoadStream(soundSet, streamName) and timeout < 100 do
        Citizen.Wait(0)
        timeout += 1
    end
    local streamId = Citizen.InvokeNative(0x0556C784FA056628, soundSet, streamName) or 0 -- GetLoadedStreamIdFromCreation
    PlayStreamFromPed(entity, streamId)
    if Lib.Util.IsDev then
        Citizen.CreateThread(function()
            local startTime = GetGameTimer()/1000
            while IsStreamPlaying(streamId) do
                Citizen.Wait(500)
            end
            Lib.Log.Debug(("Stream %s end @ %.1fs duration %.1fs"):format(streamId, GetGameTimer()/1000, (GetGameTimer()/1000) - startTime))
        end)
    end
    return streamId
end

---Convert a network audio request to call PlayStream
---@param netId integer The network id of the entity
---@param streamName string The name of the stream to play
---@param soundSet string|integer The sound set to play
local function PlayNetworkedStream(netId, streamName, soundSet)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if AudioStreams[entity] then
        StopStream(AudioStreams[entity])
        AudioStreams[entity] = nil
    end
    AudioStreams[entity] = PlayStream(entity, streamName, soundSet)
    Lib.Log.DebugVerbose("Playing stream from server on", netId, entity)
end

---Stop a networked audio stream from playing on an entity
---@param netId integer The network id of the entity
local function StopNetworkedStream(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if AudioStreams[entity] then
        StopStream(AudioStreams[entity])
        AudioStreams[entity] = nil
    end
    Lib.Log.DebugVerbose("Stopping stream:", netId, entity)
end

--- Network Event Handler for playing an audio stream from the server
RegisterNetEvent("da_lib:client:playStream")
AddEventHandler("da_lib:client:playStream", function(netId, streamName, soundSet)
    PlayNetworkedStream(netId, streamName, soundSet)
end)

--- Network Event Handler for stopping an audio stream from the server
RegisterNetEvent("da_lib:client:stopStream")
AddEventHandler("da_lib:client:stopStream", function(netId)
    StopNetworkedStream(netId)
end)

---Play a networked audio stream from an entity
---@param entity integer The entity id of the entity to play the stream from
---@param streamName string The name of the stream to play
---@param soundSet string|integer The sound set to play
Lib.Audio.PlayStream = function(entity, streamName, soundSet)
    TriggerServerEvent("da_lib:server:playStream", NetworkGetNetworkIdFromEntity(entity), streamName, soundSet)
    Lib.Log.DebugVerbose("Triggering playstream", entity, NetworkGetNetworkIdFromEntity(entity))
end

---Stop a networked audio stream from playing on an entity
---@param entity integer The entity id of the entity to stop the stream from
Lib.Audio.StopStream = function(entity)
    TriggerServerEvent("da_lib:server:stopStream", NetworkGetNetworkIdFromEntity(entity))
    Lib.Log.DebugVerbose("Stopping stream", entity, NetworkGetNetworkIdFromEntity(entity))
end
