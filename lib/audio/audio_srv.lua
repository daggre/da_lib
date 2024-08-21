--- Copyright © 2024 Joshua Nelson

RegisterNetEvent("da_lib:server:playStream")
--- Given a network id of an entity, Issue a request for all players to play a
--- stream from that entity.
---@param netId integer The network id of the entity
---@param streamName string The name of the stream to play
---@param soundSet string|integer The sound set to play
AddEventHandler("da_lib:server:playStream", function(netId, streamName, soundSet)
    local src = source
    TriggerClientEvent("da_lib:client:playStream", -1, netId, streamName, soundSet)
    Lib.Log.DebugVerbose("Playing stream", src, netId, streamName, soundSet)
end)

RegisterServerEvent("da_lib:server:stopStream")
--- Given a network id of an entity, Issue a request for all players to stop a
--- stream from playing on an entity.
---@param netId integer The network id of the entity
AddEventHandler("da_lib:server:stopStream", function(netId)
    local src = source
    TriggerClientEvent("da_lib:client:stopStream", -1, netId)
    Lib.Log.DebugVerbose("Stopping stream", src, netId)
end)
