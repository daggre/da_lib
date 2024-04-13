--- Copyright © 2024 Joshua Nelson

local AudioStreams = {}

local function PlayStream(entity, streamName, soundSet)
    soundSet = tostring(soundSet)
    local timeout = 0
    while not LoadStream(soundSet, streamName) and timeout < 100 do
        Citizen.Wait(0)
        timeout += 1
    end
    local streamId = Citizen.InvokeNative(0x0556C784FA056628, soundSet, streamName) or 0 -- GetLoadedStreamIdFromCreation
    PlayStreamFromPed(entity, streamId)
    return streamId
end

local function PlayNetworkedStream(netId, streamName, soundSet)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if AudioStreams[entity] then
        StopStream(AudioStreams[entity])
        AudioStreams[entity] = nil
    end
    AudioStreams[entity] = PlayStream(entity, streamName, soundSet)
    Lib.Log.DebugVerbose("Playing stream from server on", netId, entity)
end

local function StopNetworkedStream(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if AudioStreams[entity] then
        StopStream(AudioStreams[entity])
        AudioStreams[entity] = nil
    end
    Lib.Log.DebugVerbose("Stopping stream:", netId, entity)
end

RegisterNetEvent("da_lib:client:playStream")
AddEventHandler("da_lib:client:playStream", function(netId, streamName, soundSet)
    PlayNetworkedStream(netId, streamName, soundSet)
end)

RegisterNetEvent("da_lib:client:stopStream")
AddEventHandler("da_lib:client:stopStream", function(netId)
    StopNetworkedStream(netId)
end)

Lib.Audio.PlayStream = function(entity, streamName, soundSet)
    TriggerServerEvent("da_lib:server:playStream", NetworkGetNetworkIdFromEntity(entity), streamName, soundSet)
    Lib.Log.DebugVerbose("Triggering playstream", entity, NetworkGetNetworkIdFromEntity(entity))
end

Lib.Audio.StopStream = function(entity)
    TriggerServerEvent("da_lib:server:stopStream", NetworkGetNetworkIdFromEntity(entity))
    Lib.Log.DebugVerbose("Stopping stream", entity, NetworkGetNetworkIdFromEntity(entity))
end
