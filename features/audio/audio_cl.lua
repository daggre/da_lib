local AudioStreams = {}

local _loadStream = function(soundSet, streamName)
    local tick = 0
    while not LoadStream(soundSet, streamName) and tick < 100 do
        Citizen.Wait(0)
        tick = tick + 1
    end
end

local audio = {
    play = function(entity, streamName, soundSet)
        soundSet = tostring(soundSet)
        TriggerServerEvent("da_lib.audio.playStream", NetworkGetNetworkIdFromEntity(entity), streamName, soundSet)
    end,
    stop = function(entity)
        TriggerServerEvent("da_lib.audio.stopStream", NetworkGetNetworkIdFromEntity(entity))
    end,
}

RegisterNetEvent("da_lib.audio.playStream")
AddEventHandler("da_lib.audio.playStream", function(netId, streamName, soundSet)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if AudioStreams[netId] then
        TriggerServerEvent("da_lib.audio.stopStream", netId)
    end
    _loadStream(soundSet, streamName)
    local streamId = Citizen.InvokeNative(0x0556C784FA056628, soundSet, streamName) or 0 -- GetLoadedStreamIdFromCreation
    AudioStreams[netId] = streamId
    PlayStreamFromPed(entity, streamId)
    log.spam("Playing networked stream", netId, entity)
end)

RegisterNetEvent("da_lib.audio.stopStream")
AddEventHandler("da_lib.audio.stopStream", function(netId)
    if AudioStreams[netId] then
        StopStream(AudioStreams[netId])
        AudioStreams[netId] = nil
    end
    log.spam("Stopping networked stream", netId)
end)

_ENV.da_audio = audio
