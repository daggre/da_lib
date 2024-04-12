RegisterServerEvent("da_lib:server:playStream")
AddEventHandler("da_lib:server:playStream", function(netId, streamName, soundSet)
    local src = source
    TriggerClientEvent("da_lib:client:playStream", -1, netId, streamName, soundSet)
    Lib.Log.DebugVerbose("Playing stream", src, netId, streamName, soundSet)
end)

RegisterServerEvent("da_lib:server:stopStream")
AddEventHandler("da_lib:server:stopStream", function(netId)
    local src = source
    TriggerClientEvent("da_lib:client:stopStream", -1, netId)
    Lib.Log.DebugVerbose("Stopping stream", src, netId)
end)
