--- Copyright © 2024 Joshua Nelson

-- Animate an NPC Ped on this client when requested by the server
RegisterNetEvent("da_lib:npc:animate")
AddEventHandler("da_lib:npc:animate", function(id, options)
    Lib.Log.Debug("NPC animate", id, options)
    if Lib.API.Active then
        Lib.API.SetNPCAnimate(id, options)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("npc:animate"))
end)

NpcDynamicStates = {}
-- Request an NPC ped to animate across all clients
Lib.NPC.Animate = function(id, options)
    if Lib.API.Active then
        if not NpcDynamicStates[id] or NpcDynamicStates[id] ~= options or Lib.Cache.Lazy.Delay("npcState", id, 2*60*1000) then
            Lib.Log.Debug("Syncing NPC animate", id, options)
            NpcDynamicStates[id] = options
            Lib.API.RequestNPCAnimate(id, options)
            return
        else
            -- Even if we aren't syncing globally, force locally
            Lib.Log.Debug("Local sync of NPC animate", id, options)
            Lib.API.SetNPCAnimate(id, options)
            return
        end
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("NPC.Animate"))
end

--  Create a registered NPC ped
Lib.NPC.New = function(modelHash, coords, options)
    if Lib.API.Active then
        return Lib.API.CreatePed(modelHash, coords, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("NPC.New"))
end
