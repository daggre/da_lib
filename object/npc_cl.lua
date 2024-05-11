RegisterNetEvent("da_lib:npc:animate")
AddEventHandler("da_lib:npc:animate", function()
    if Lib.API.Active then
        Lib.API.SetNPCAnimate(id, options)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("npc:animate"))
end)

Lib.NPC.Animate = function(id, options)
    if Lib.API.Active then
        Lib.API.RequestNPCAnimate(id, options)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("NPC.Animate"))
end

Lib.NPC.New = function(modelHash, coords, options)
    if Lib.API.Active then
        return Lib.API.CreatePed(modelHash, coords, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("NPC.New"))
end
