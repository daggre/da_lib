--- Copyright © 2024 Joshua Nelson

-- Animate an NPC Ped on this client when requested by the server
RegisterNetEvent("da_lib:npc:animate")
AddEventHandler("da_lib:npc:animate", function()
    if Lib.API.Active then
        Lib.API.SetNPCAnimate(id, options)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("npc:animate"))
end)

-- Request an NPC ped to animate across all clients
Lib.NPC.Animate = function(id, options)
    if Lib.API.Active then
        Lib.API.RequestNPCAnimate(id, options)
        return
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
