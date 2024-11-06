--- Copyright © 2024 Joshua Nelson

-- Animate an NPC Ped on this client when requested by the server
RegisterNetEvent("da_lib:npc:animate")
AddEventHandler("da_lib:npc:animate", function(id, options)
    log.debug("NPC animate", id, options)
    API.setNPCAnimate(id, options)
end)

NpcDynamicStates = {}
-- Request an NPC ped to animate across all clients
NPC.Animate = function(id, options)
    if not NpcDynamicStates[id] or NpcDynamicStates[id] ~= options or delay["npcState_"..id](2*60*1000) then
        log.debug("Syncing NPC animate", id, options)
        NpcDynamicStates[id] = options
        API.requestNPCAnimate(id, options)
        return
    else
        -- Even if we aren't syncing globally, force locally
        log.debug("Local sync of NPC animate", id, options)
        API.setNPCAnimate(id, options)
        return
    end
end

--  Create a registered NPC ped
NPC.New = function(modelHash, coords, options)
    return API.createPed(modelHash, coords, options)
end
