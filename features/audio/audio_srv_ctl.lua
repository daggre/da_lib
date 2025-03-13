RegisterNetEvent("da_lib.audio.playStream")
--- Given a network id of an entity, Issue a request for all players to play a
--- stream from that entity.
---@param netId integer The network id of the entity
---@param streamName string The name of the stream to play
---@param soundSet string|integer The sound set to play
AddEventHandler("da_lib.audio.playStream", function(netId, streamName, soundSet)
    local src = source
    TriggerClientEvent("da_lib.audio.playStream", -1, netId, streamName, soundSet)
    log.spam("Playing stream src:" .. src .. " netId:" .. netId .. " name:" .. streamName .. " soundSet:" .. soundSet)
end)

RegisterServerEvent("da_lib.audio.stopStream")
--- Given a network id of an entity, Issue a request for all players to stop a
--- stream from playing on an entity.
---@param netId integer The network id of the entity
AddEventHandler("da_lib.audio.stopStream", function(netId)
    local src = source
    TriggerClientEvent("da_lib.audio.stopStream", -1, netId)
    log.spam("Stopping stream src:" .. src .. " netId:" .. netId)
end)
